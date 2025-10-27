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
  source_path         = "${get_terragrunt_dir()}/../../../../lambda-src/layers/common-utils/dist/common-utils-layer.zip"
}