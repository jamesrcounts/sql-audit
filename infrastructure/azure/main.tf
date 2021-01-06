locals {
  project = "sql-audit"

  tags = {
    project = local.project
  }
}

resource "random_pet" "fido" {}