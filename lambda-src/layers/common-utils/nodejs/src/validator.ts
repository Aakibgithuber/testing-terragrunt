/**
 * Environment variable validation
 */

export interface ValidationResult {
  isValid: boolean;
  missing: string[];
}

export function validateEnvVars(required: string[]): ValidationResult {
  const missing: string[] = [];

  for (const varName of required) {
    if (!process.env[varName]) {
      missing.push(varName);
    }
  }

  return {
    isValid: missing.length === 0,
    missing,
  };
}

export function requireEnvVars(required: string[]): void {
  const result = validateEnvVars(required);

  if (!result.isValid) {
    throw new Error(
      `Missing required environment variables: ${result.missing.join(", ")}`
    );
  }
}