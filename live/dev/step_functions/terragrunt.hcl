terraform {
  source = "../../../modules/step_functions"
}

include {
  path = find_in_parent_folders()
}

dependency "push_to_db" {
  config_path = "../lambdas/push_to_db"
}

dependency "find_diff_schema" {
  config_path = "../lambdas/find_diff_schema"
}

dependency "ai_category_finder" {
  config_path = "../lambdas/ai_category_finder"
}

dependency "load_to_mongo" {
  config_path = "../lambdas/load_to_mongo"
}


inputs = {
  name      = "navirego-dev-step-function"
  region    = "ap-south-1"
  role_name = "navirego-stepfunction-role"
  project_name = "navirego-data-pipeline"
  environment  = "dev"

  definition = jsonencode({
    Comment = "navirego multi-step ingestion workflow"
    StartAt = "PushToDB"
    States = {
      PushToDB = {
        Type     = "Task"
        Resource = dependency.push_to_db.outputs.lambda_arn
        Next     = "FindDiffSchema"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "FailureHandler"
        }]
      },
      FindDiffSchema = {
        Type     = "Task"
        Resource = dependency.find_diff_schema.outputs.lambda_arn
        Next     = "AICategoryFinder"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "FailureHandler"
        }]
      },
      AICategoryFinder = {
        Type     = "Task"
        Resource = dependency.ai_category_finder.outputs.lambda_arn
        Next     = "LoadToMongo"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "FailureHandler"
        }]
      },
      LoadToMongo = {
        Type     = "Task"
        Resource = dependency.load_to_mongo.outputs.lambda_arn
        End      = true
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "FailureHandler"
        }]
      },
      FailureHandler = {
        Type = "Fail"
        Error = "TaskFailed"
        Cause = "Lambda execution failed"
      }
    }
  })
  

  s3_bucket_name = get_env("TF_VAR_S3_BUCKET_NAME", "my-default-s3-bucket")
}
