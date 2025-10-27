/**
 * SFTP Data Dump Lambda Function
 * Downloads files from SFTP server and uploads to S3
 */

// Import from Layer 1 (common-utils)
import { Logger, retryWithBackoff, requireEnvVars } from "/opt/nodejs/dist";

// Import from Layer 2 (aws-dependencies)
import { S3Client, HeadObjectCommand } from "@aws-sdk/client-s3";
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { Upload } from "@aws-sdk/lib-storage";

// Import from Layer 3 (heavy-dependencies)
// Note: require() is used for CommonJS modules in layers
const SFTPClient = require("/opt/nodejs/node_modules/ssh2-sftp-client");

// Lambda types
import { Handler, Context } from "aws-lambda";

// Initialize logger
const logger = new Logger({
  service: "sftp-data-dump",
  environment: process.env.ENVIRONMENT || "dev",
});

// Validate required environment variables
requireEnvVars([
  "SFTP_HOST",
  "SFTP_PORT",
  "REGION",
  "APP_NAME",
  "ENVIRONMENT",
  "SFTP_SQL_DIR",
]);

const REGION = process.env.REGION!;
const S3_BUCKET = `${process.env.APP_NAME}-${process.env.ENVIRONMENT}-sftp-dump`;

const smClient = new SecretsManagerClient({ region: REGION });
const s3Client = new S3Client({ region: REGION });

interface LambdaEvent {
  organizationId: string;
}

interface SFTPCredentials {
  username: string;
  password: string;
  organizationId: string;
}

/**
 * Fetch credentials from AWS Secrets Manager
 */
async function fetchCredentials(
  organizationId: string
): Promise<SFTPCredentials> {
  logger.info("Fetching credentials", { organizationId });

  const secretName = `navirego/${process.env.ENVIRONMENT}/sftp/${organizationId}`;

  const command = new GetSecretValueCommand({ SecretId: secretName });
  const response = await smClient.send(command);

  if (!response.SecretString) {
    throw new Error("Secret has no value");
  }

  const secret = JSON.parse(response.SecretString);

  return {
    username: secret.username,
    password: secret.password,
    organizationId,
  };
}

/**
 * Connect to SFTP and upload files to S3
 */
async function uploadFilesToS3(
  credentials: SFTPCredentials
): Promise<{ filesProcessed: number; failedFiles: string[] }> {
  const sftp = new SFTPClient();
  const failedFiles: string[] = [];

  try {
    // Connect to SFTP
    await retryWithBackoff(
      async () => {
        logger.info("Connecting to SFTP...", { host: process.env.SFTP_HOST });
        await sftp.connect({
          host: process.env.SFTP_HOST,
          port: parseInt(process.env.SFTP_PORT || "22"),
          username: credentials.username,
          password: credentials.password,
        });
      },
      { maxRetries: 3, delayMs: 2000 }
    );

    logger.info("Connected to SFTP successfully");

    // List files
    const sftpDir = process.env.SFTP_SQL_DIR!;
    const fileList = await sftp.list(sftpDir);

    logger.info("Files found", { count: fileList.length });

    // Process each file
    let processed = 0;
    for (const file of fileList) {
      if (file.type !== "-" && file.type !== "file") continue;

      const remotePath = `${sftpDir}/${file.name}`;
      const s3Key = `${credentials.organizationId}/SQL_DB/${file.name}`;

      try {
        // Check if file already exists in S3
        try {
          await s3Client.send(
            new HeadObjectCommand({
              Bucket: S3_BUCKET,
              Key: s3Key,
            })
          );
          logger.info("File already exists in S3, skipping", {
            fileName: file.name,
          });
          continue;
        } catch (err: any) {
          if (err.name !== "NotFound") throw err;
        }

        // Download from SFTP and upload to S3
        logger.info("Processing file", { fileName: file.name });

        const stream = await sftp.get(remotePath);

        const uploader = new Upload({
          client: s3Client,
          params: {
            Bucket: S3_BUCKET,
            Key: s3Key,
            Body: stream,
          },
        });

        await uploader.done();

        logger.info("File uploaded successfully", { fileName: file.name });
        processed++;
      } catch (error) {
        logger.error("Failed to process file", {
          fileName: file.name,
          error: error instanceof Error ? error.message : "Unknown error",
        });
        failedFiles.push(file.name);
      }
    }

    return { filesProcessed: processed, failedFiles };
  } finally {
    await sftp.end().catch(() => {});
    logger.info("SFTP connection closed");
  }
}

/**
 * Lambda handler
 */
export const handler: Handler<LambdaEvent> = async (
  event,
  context: Context
) => {
  logger.addContext({
    requestId: context.awsRequestId,
    functionName: context.functionName,
  });

  logger.info("Lambda invoked", { event });

  const { organizationId } = event;

  if (!organizationId) {
    logger.error("Missing organizationId in event");
    throw new Error("organizationId is required");
  }

  try {
    // Fetch credentials
    const credentials = await retryWithBackoff(
      () => fetchCredentials(organizationId),
      { maxRetries: 3, delayMs: 1000 }
    );

    // Upload files
    const result = await uploadFilesToS3(credentials);

    logger.info("Processing completed", {
      filesProcessed: result.filesProcessed,
      failedFiles: result.failedFiles.length,
      organizationId,
    });

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Files processed successfully",
        filesProcessed: result.filesProcessed,
        failedFiles: result.failedFiles,
      }),
    };
  } catch (error) {
    logger.error("Lambda execution failed", {
      error: error instanceof Error ? error.message : "Unknown error",
      stack: error instanceof Error ? error.stack : undefined,
      organizationId,
    });
    throw error;
  }
};