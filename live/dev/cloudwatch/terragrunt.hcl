terraform {
  source = "../../../modules/cloudwatch"
}

include {
  path = find_in_parent_folders()
}

# ---------------- Dependencies ----------------
dependency "sns" {
  config_path = "../sns"
}

dependency "step_functions" {
  config_path = "../step_functions"
}

dependency "sqs_dlq_push_to_db" {
  config_path = "../sqs_dlq/push_to_db"
}

dependency "sqs_dlq_ai_category_finder" {
  config_path = "../sqs_dlq/ai_category_finder"
}

dependency "sqs_dlq_find_diff_schema" {
  config_path = "../sqs_dlq/find_diff_schema"
}

dependency "sqs_dlq_load_to_mongo" {
  config_path = "../sqs_dlq/load_to_mongo"
}

dependency "sqs_dlq_sftp_dump" {
  config_path = "../sqs_dlq/sftp_dump"
}

# ---------------- Inputs ----------------
inputs = {
  sns_topic_arn     = dependency.sns.outputs.topic_arn
  step_function_arn = dependency.step_functions.outputs.state_machine_arn
  dlq_arns = [
    dependency.sqs_dlq_push_to_db.outputs.queue_arn,
    dependency.sqs_dlq_ai_category_finder.outputs.queue_arn,
    dependency.sqs_dlq_find_diff_schema.outputs.queue_arn,
    dependency.sqs_dlq_load_to_mongo.outputs.queue_arn,
    dependency.sqs_dlq_sftp_dump.outputs.queue_arn,
  ]
  environment = "dev"

  # DLQ alarm values
  dlq_alarm_prefix          = "DLQ-Messages"
  dlq_comparison_operator   = "GreaterThanThreshold"
  dlq_evaluation_periods    = 1
  dlq_datapoints_to_alarm   = 1
  dlq_metric_name           = "ApproximateNumberOfMessagesVisible"
  dlq_namespace             = "AWS/SQS"
  dlq_period                = 60
  dlq_statistic             = "Sum"
  dlq_threshold             = 0
  dlq_treat_missing_data    = "notBreaching"
  dlq_alarm_description     = "Messages present in DLQ. Possible failure in Lambda/Step Function."

  # Step function alarm values
  step_function_alarm_prefix         = "StepFunction-Failures"
  step_function_comparison_operator  = "GreaterThanThreshold"
  step_function_evaluation_periods   = 1
  step_function_metric_name          = "ExecutionsFailed"
  step_function_namespace            = "AWS/States"
  step_function_period               = 60
  step_function_statistic            = "Sum"
  step_function_threshold            = 0
  step_function_alarm_description    = "Step Function executions are failing."
}
