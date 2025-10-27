terraform {
  source = "../../../modules/cloudtrail"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name            = "navirego-sftp"
  environment     = "dev"
  s3_bucket_name  = get_env("TF_VAR_S3_BUCKET_NAME")
  project_name    = "Navirego-data-pipeline"
}
