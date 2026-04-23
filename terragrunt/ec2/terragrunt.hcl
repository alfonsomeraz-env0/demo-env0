include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id           = "vpc-00000000"
    public_subnet_id = "subnet-00000000"
    vpc_cidr         = "10.0.0.0/16"
  }
}

dependency "security_groups" {
  config_path = "../security_groups"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    ec2_security_group_id      = "sg-00000000"
    s3_access_security_group_id = "sg-00000001"
  }
}

dependency "iam" {
  config_path = "../iam"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    ec2_instance_profile_name = "mock-ec2-profile"
    ec2_role_arn              = "arn:aws:iam::000000000000:role/mock-ec2-role"
  }
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
