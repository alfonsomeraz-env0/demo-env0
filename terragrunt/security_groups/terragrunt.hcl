terraform {
  source = "../../terraform/modules/security_groups"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  environment       = "dev"
  vpc_id            = dependency.vpc.outputs.vpc_id
  allowed_ssh_cidrs = ["0.0.0.0/0"]
}
