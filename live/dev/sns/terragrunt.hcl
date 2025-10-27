terraform {
  source = "../../../modules/sns"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "navirego-data-pipeline"
  environment  = "dev"
  email        = "aakibkhan4044@gmail.com"
}
