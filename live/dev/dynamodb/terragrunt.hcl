terraform {
  source = "../../../modules/dynamodb"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_name = "navirego-data-pipeline"
  environment  = "dev"
}
