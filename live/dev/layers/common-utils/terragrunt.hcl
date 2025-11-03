terraform {
  source = "../../../../modules/lambda_layer"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  layer_name          = "navirego-common-utils-dev"
  description         = "Common TypeScript utilities for Navirego Lambda functions"
  compatible_runtimes = ["nodejs20.x", "nodejs18.x"]
  s3_bucket           = "navirego-lambda-layers-dev"
  s3_key              = "lambda-layers/common-utils/common-utils-layer.zip"
}