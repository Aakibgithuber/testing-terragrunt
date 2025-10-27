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

dependency "dlq" {
  config_path = "../../sqs_dlq/ai_category_finder"
}

inputs = {
  function_name = "navirego-ai-category-finder-dev"
  environment   = "dev"
  handler = "index.handler"
  runtime = "nodejs20.x"
  timeout = 15
  memory_size = 128
  directory = "ai_category_finder"

  # Attach all 3 layers
  lambda_layers = [
    dependency.layer_common.outputs.layer_arn,
    dependency.layer_aws.outputs.layer_arn,
    dependency.layer_heavy.outputs.layer_arn
  ]

  dead_letter_target_arn = dependency.dlq.outputs.queue_arn
}