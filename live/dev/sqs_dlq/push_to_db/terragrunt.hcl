terraform {
  source = "../../../../modules/sqs_dlq"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name        = "push-to-db"
  environment = "dev"
}
