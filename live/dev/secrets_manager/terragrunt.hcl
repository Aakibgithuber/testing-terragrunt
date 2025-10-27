# infra/live/dev/secrets_manager/terragrunt.hcl
terraform {
  source = "../../../modules/secrets_manager"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name          = "navirego/dev/sftp/CMBTech"
  secret_string = jsonencode({
    username = "cmbtech_dtaex_sftp"
    password = get_env("TF_VAR_SFTP_PASS")
  })
}
