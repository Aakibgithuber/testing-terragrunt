remote_state {
  backend = "s3"

  config = {
    bucket         = "navirego-lambda-layers-dev"        # state bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"  # folder-specific key
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
