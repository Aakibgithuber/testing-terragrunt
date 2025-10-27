terraform {
  source = "../../../modules/rds"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "navirego-data-pipeline"
  environment  = "dev"

  # RDS credentials
  db_username = "navirego_admin"
  db_password = get_env("TF_VAR_DB_PASSWORD")
}
