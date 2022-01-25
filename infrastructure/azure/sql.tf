locals {
  database_id = "${azurerm_mssql_server.example.id}/databases/master"
}

resource "azurerm_mssql_server" "example" {
  administrator_login          = "missadministrator"
  administrator_login_password = "AdminPassword123!"
  location                     = azurerm_resource_group.example.location
  minimum_tls_version          = "1.2"
  name                         = "${local.project}-${random_pet.fido.id}"
  resource_group_name          = azurerm_resource_group.example.name
  tags                         = local.tags
  version                      = "12.0"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "example" {
  log_monitoring_enabled = true
  server_id              = azurerm_mssql_server.example.id
}

resource "azurerm_mssql_database_extended_auditing_policy" "master" {
  database_id            = local.database_id
  log_monitoring_enabled = true
}


resource "azurerm_mssql_database" "test" {
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  name           = "acctest-db-d"
  read_scale     = true
  server_id      = azurerm_mssql_server.example.id
  sku_name       = "BC_Gen5_2"
  tags           = local.tags
  zone_redundant = true
}

resource "azurerm_mssql_database_extended_auditing_policy" "test" {
  database_id            = azurerm_mssql_database.test.id
  log_monitoring_enabled = true
}

module "diagnostics" {
  source                     = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=main"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  monitored_services = {
    "audit-db" = local.database_id
    "test-db"  = azurerm_mssql_database.test.id
    sql        = azurerm_mssql_server.example.id
  }
}