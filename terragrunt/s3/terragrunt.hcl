include "root" {
  path = find_in_parent_folders()
}

inputs = {
  environment               = "dev"
  bucket_name               = "demo-env0-dev-alfonso"
  version_retention_days    = 30
  enable_lifecycle_archival = false
  archive_transition_days   = 90
}
