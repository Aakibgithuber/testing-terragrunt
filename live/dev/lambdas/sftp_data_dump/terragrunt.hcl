terraform {
  source = "../../../../modules/lambda"
}

include {
  path = find_in_parent_folders()
}

# Dependencies on layers
dependency "layer_common" {
  config_path = "../../layers/common-utils"
}

dependency "layer_aws" {
  config_path = "../../layers/aws-dependencies"
}

dependency "layer_heavy" {
  config_path = "../../layers/heavy-dependencies"
}

# Dependency on DLQ
dependency "dlq" {
  config_path = "../../sqs_dlq/sftp_dump"
}

inputs = {
  function_name = "navirego-sftp-data-dump-dev"
  environment   = "dev"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 300
  memory_size   = 512
  directory     = "sftp_data_dump"

  # Attach all 3 layers
  lambda_layers = [
    dependency.layer_common.outputs.layer_arn,
    dependency.layer_aws.outputs.layer_arn,
    dependency.layer_heavy.outputs.layer_arn
  ]

  # DLQ configuration
  dead_letter_target_arn = dependency.dlq.outputs.queue_arn

  # SFTP configuration
  sftp_host = "file.aegroup.biz"
  sftp_port = 22
  sftp_sql_dir = "/SQL DB"
  region = "ap-south-1"
  app_name = "navirego"
}