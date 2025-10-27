terraform {
  backend "s3" {}
}

# Step Function IAM Role (allow both Step Functions + EventBridge)
resource "aws_iam_role" "stepfunction_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "states.amazonaws.com",
            "events.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Basic policy so Step Function can log and invoke Lambda
resource "aws_iam_role_policy" "stepfunction_policy" {
  name = "StepFunctionBasePolicy"
  role = aws_iam_role.stepfunction_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction",
          "logs:*",
          "states:StartExecution"
        ],
        Resource = "*"
      }
    ]
  })
}

# Step Function definition
resource "aws_sfn_state_machine" "this" {
  name       = var.name
  role_arn   = aws_iam_role.stepfunction_role.arn
  definition = var.definition

  tags = {
    ManagedBy   = "Terraform"
    Environment = "${var.environment}"
    Project     = "${var.project_name}"
  }
}

# EventBridge rule to detect S3 uploads
resource "aws_cloudwatch_event_rule" "s3_upload_rule" {
  name        = "trigger-step-function-on-upload"
  description = "Trigger Step Function when new file uploaded to S3"
  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["PutObject"]
      requestParameters = {
        bucketName = [var.s3_bucket_name]
      }
    }
  })
}

# Connect EventBridge rule to Step Function
resource "aws_cloudwatch_event_target" "start_step_function" {
  rule      = aws_cloudwatch_event_rule.s3_upload_rule.name
  target_id = "StartnaviregoStepFunction"
  arn       = aws_sfn_state_machine.this.arn
  role_arn  = aws_iam_role.stepfunction_role.arn
}
