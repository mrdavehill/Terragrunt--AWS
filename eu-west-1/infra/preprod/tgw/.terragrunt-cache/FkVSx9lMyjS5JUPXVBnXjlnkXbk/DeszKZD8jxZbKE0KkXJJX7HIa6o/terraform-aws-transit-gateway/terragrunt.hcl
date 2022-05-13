include "root" {
  path = find_in_parent_folders()
}

include "tgw" {
  path = "${get_terragrunt_dir()}/../../../../_env/tgw.hcl"
}