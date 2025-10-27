terraform {
  source = "../../../modules/s3"
}

include {
  path = find_in_parent_folders()
}


inputs = {
  bucket_name = get_env("TF_VAR_S3_BUCKET_NAME")
  environment = "dev"
  tags = {
    Project = "navirego Data Pipeline"
    Owner   = "NAVIREGO"
  }
}
