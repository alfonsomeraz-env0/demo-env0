include "root" {
  path = find_in_parent_folders()
}

inputs = {
  instance_type = "t2.micro"
  instance_name = "demo-env0-free-tier"
}
