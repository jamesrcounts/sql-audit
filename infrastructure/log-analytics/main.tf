locals {
  project = "sql-audit"

  tags = {
    project   = local.project
    workspace = terraform.workspace
  }
}

resource "random_pet" "fido" {}