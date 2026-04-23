include "root" {
  path = find_in_parent_folders()
}

dependency "s3" {
  config_path = "../s3"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    bucket_id          = "mock-bucket"
    bucket_arn         = "arn:aws:s3:::mock-bucket"
    bucket_domain_name = "mock-bucket.s3.amazonaws.com"
  }
}

inputs = {
  environment    = "dev"
  s3_bucket_name = dependency.s3.outputs.bucket_id
}
