terraform {
  source = "../../terraform/modules/iam"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "s3" {
  config_path = "../s3"
}

inputs = {
  environment    = "dev"
  s3_bucket_name = dependency.s3.outputs.bucket_id
}
