terraform {
  source = "../../../../modules/lambda_layer"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  layer_name          = "navirego-heavy-deps-dev"
  description         = "Heavy libraries (SFTP, SSH2) for Navirego Lambda functions"
  compatible_runtimes = ["nodejs20.x", "nodejs18.x"]
  s3_bucket           = "navirego-lambda-layers-dev"
  s3_key              = "lambda-layers/heavy-dependencies/heavy-dependencies-layer.zip"
}