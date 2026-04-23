include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["workspace", "init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs = {
    vpc_id           = "vpc-00000000"
    public_subnet_id = "subnet-00000000"
    vpc_cidr         = "10.0.0.0/16"
  }
}

inputs = {
  environment       = "dev"
  vpc_id            = dependency.vpc.outputs.vpc_id
  allowed_ssh_cidrs = ["0.0.0.0/0"]
}
