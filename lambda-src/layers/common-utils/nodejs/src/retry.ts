/**
 * Retry utility with exponential backoff
 */

export interface RetryOptions {
  maxRetries?: number;
  delayMs?: number;
  backoffMultiplier?: number;
  maxDelayMs?: number;
}

export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const {
    maxRetries = 3,
    delayMs = 1000,
    backoffMultiplier = 2,
    maxDelayMs = 10000,
  } = options;

  let attempt = 0;
  let currentDelay = delayMs;

  while (attempt < maxRetries) {
    try {
      return await fn();
    } catch (error) {
      attempt++;

      if (attempt >= maxRetries) {
        throw new Error(
          `Operation failed after ${maxRetries} attempts: ${
            error instanceof Error ? error.message : "Unknown error"
          }`
        );
      }

      console.warn(
        `Attempt ${attempt} failed, retrying in ${currentDelay}ms...`
      );
      await new Promise((resolve) => setTimeout(resolve, currentDelay));

      currentDelay = Math.min(currentDelay * backoffMultiplier, maxDelayMs);
    }
  }

  throw new Error("Retry loop exited unexpectedly");
}