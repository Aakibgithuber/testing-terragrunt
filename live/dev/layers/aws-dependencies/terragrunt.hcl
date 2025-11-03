terraform {
  source = "../../../../modules/lambda_layer"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  layer_name          = "navirego-aws-deps-dev"
  description         = "AWS SDK packages for Navirego Lambda functions"
  compatible_runtimes = ["nodejs20.x", "nodejs18.x"]
  s3_bucket           = "navirego-lambda-layers-dev"
  s3_key              = "lambda-layers/aws-dependencies/aws-dependencies-layer.zip"
}