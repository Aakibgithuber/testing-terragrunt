remote_state {
  backend = "s3"

  config = {
    bucket         = "github-navirego-dev-sftp-dump12122"        # state bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"  # folder-specific key
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
