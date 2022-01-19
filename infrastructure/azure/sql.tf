locals {
  database_id = "${azurerm_mssql_server.example.id}/databases/master"
}

resource "azurerm_mssql_server" "example" {
  name                         = "${local.project}-${random_pet.fido.id}"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "AdminPassword123!"
  tags                         = local.tags
  minimum_tls_version          = "1.2"

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_log_analytics_workspace" "logs" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "${local.project}-${random_pet.fido.id}"
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = local.tags
}

# TODO: This solution might be what the port is looking for but I'm getting a failure response from Azure when trying to deploy.
# I also tried creating the solution in the portal and importing it, but also getting an error there.
resource "azurerm_log_analytics_solution" "insights" {
  solution_name         = "SQLAuditing"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  workspace_resource_id = azurerm_log_analytics_workspace.logs.id
  workspace_name        = azurerm_log_analytics_workspace.logs.name
  tags                  = local.tags

  plan {
    publisher = "Microsoft"
    product   = "SQLAuditing"
  }
}

data "azurerm_client_config" "current" {}

module "diagnostics" {
  source                     = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=main"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  monitored_services = {
    master = local.database_id
    server = azurerm_mssql_server.example.id
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "example" {
  server_id              = azurerm_mssql_server.example.id
  log_monitoring_enabled = true
}

resource "azurerm_mssql_database_extended_auditing_policy" "audit_master" {
  depends_on             = [azurerm_mssql_server_extended_auditing_policy.example]
  database_id            = local.database_id
  log_monitoring_enabled = true
}