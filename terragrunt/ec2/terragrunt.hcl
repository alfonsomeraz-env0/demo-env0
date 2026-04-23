terraform {
  source = "../../terraform/modules/ec2"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security_groups"
}

dependency "iam" {
  config_path = "../iam"
}

inputs = {
  environment               = "dev"
  instance_name             = "demo-env0"
  instance_type             = "t2.micro"
  subnet_id                 = dependency.vpc.outputs.public_subnet_id
  security_group_ids        = [dependency.security_groups.outputs.ec2_security_group_id]
  iam_instance_profile_name = dependency.iam.outputs.ec2_instance_profile_name
  root_volume_size          = 20
}
