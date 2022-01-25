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

data "azurerm_mssql_database" "master" {
  name      = "master"
  server_id = azurerm_mssql_server.example.id
}

resource "azurerm_mssql_server_extended_auditing_policy" "example" {
  log_monitoring_enabled = true
  server_id              = azurerm_mssql_server.example.id
}

resource "azurerm_mssql_database_extended_auditing_policy" "master" {
  database_id            = data.azurerm_mssql_database.master.id
  log_monitoring_enabled = true
}

module "diagnostics" {
  source                     = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=main"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  monitored_services = {
    "audit-db" = data.azurerm_mssql_database.master.id
  }
}
