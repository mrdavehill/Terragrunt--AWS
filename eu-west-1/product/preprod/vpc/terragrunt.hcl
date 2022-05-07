include "root" {
  path = find_in_parent_folders()
}

include "vpc" {
  path = "${get_terragrunt_dir()}/../../../../_env/vpc.hcl"
}