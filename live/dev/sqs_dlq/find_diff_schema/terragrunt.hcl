terraform {
  source = "../../../../modules/sqs_dlq"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name     = "find-diff-schema"
  environment = "dev"
}
