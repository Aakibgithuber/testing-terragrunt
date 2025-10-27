/**
 * Structured logger for Lambda functions
 * Outputs JSON logs for CloudWatch Insights
 */

export interface LogContext {
  requestId?: string;
  userId?: string;
  organizationId?: string;
  [key: string]: any;
}

export enum LogLevel {
  DEBUG = "debug",
  INFO = "info",
  WARN = "warn",
  ERROR = "error",
}

export class Logger {
  private context: LogContext;

  constructor(context: LogContext = {}) {
    this.context = context;
  }

  private log(level: LogLevel, message: string, meta?: any): void {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      context: this.context,
      ...meta,
    };
    console.log(JSON.stringify(logEntry));
  }

  info(message: string, meta?: any): void {
    this.log(LogLevel.INFO, message, meta);
  }

  error(message: string, meta?: any): void {
    this.log(LogLevel.ERROR, message, meta);
  }

  warn(message: string, meta?: any): void {
    this.log(LogLevel.WARN, message, meta);
  }

  debug(message: string, meta?: any): void {
    this.log(LogLevel.DEBUG, message, meta);
  }

  addContext(context: LogContext): void {
    this.context = { ...this.context, ...context };
  }
}