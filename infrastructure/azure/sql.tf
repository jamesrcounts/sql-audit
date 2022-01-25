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
  depends_on = [azurerm_mssql_server.example]

  log_monitoring_enabled = true
  server_id              = azurerm_mssql_server.example.id
}

resource "azurerm_mssql_database_extended_auditing_policy" "master" {
  depends_on = [azurerm_mssql_server.example]

  database_id            = data.azurerm_mssql_database.master.id
  log_monitoring_enabled = true
}

data "azurerm_monitor_diagnostic_categories" "example" {
  resource_id = data.azurerm_mssql_database.master.id
}

resource "azurerm_monitor_diagnostic_setting" "audit" {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  name                       = "diag-audit-db"
  target_resource_id         = data.azurerm_mssql_database.master.id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.example.logs

    content {
      category = log.value
      enabled  = true

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.example.metrics

    content {
      category = metric.value
      enabled  = true

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }
}