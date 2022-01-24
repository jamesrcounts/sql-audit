locals {
  database_id = "${azurerm_mssql_server.example.id}/databases/master"
}

// {
//   "type": "Microsoft.Sql/servers",
//   "apiVersion": "2019-06-01-preview",
//   "location": "[parameters('location')]",
//   "name": "[parameters('sqlServerName')]",
//   "properties": {
//     "administratorLogin": "[parameters('sqlAdministratorLogin')]",
//     "administratorLoginPassword": "[parameters('sqlAdministratorLoginPassword')]",
//     "version": "12.0"
//   },
//   "tags": {
//     "DisplayName": "[parameters('sqlServerName')]"
//   },
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

// {
//   "type": "databases",
//   "apiVersion": "2017-03-01-preview",
//   "location": "[parameters('location')]",
//   "dependsOn": [
//     "[parameters('sqlServerName')]"
//   ],
//   "name": "master",
//   "properties": {}
// },
data "azurerm_mssql_database" "master" {
  name      = "master"
  server_id = azurerm_mssql_server.example.id
}

// {
//   "type": "databases/providers/diagnosticSettings",
//   "name": "[concat('master/microsoft.insights/',variables('diagnosticSettingsName'))]",
//   "dependsOn": [
//     "[parameters('sqlServerName')]",
//     "[resourceId('Microsoft.OperationalInsights/workspaces', parameters('omsWorkspaceName'))]",
//     "[resourceId('Microsoft.Sql/servers/databases', parameters('sqlServerName'), 'master')]"
//   ],
//   "apiVersion": "2017-05-01-preview",
//   "properties": {
//     "name": "[variables('diagnosticSettingsName')]",
//     "workspaceId": "[resourceId('Microsoft.OperationalInsights/workspaces', parameters('omsWorkspaceName'))]",
//     "logs": [
//       {
//         "category": "SQLSecurityAuditEvents",
//         "enabled": true,
//         "retentionPolicy": {
//           "days": 0,
//           "enabled": false
//         }
//       },
//       {
//         "condition": "[parameters('isMSDevOpsAuditEnabled')]",
//         "category": "DevOpsOperationsAudit",
//         "enabled": true,
//         "retentionPolicy": {
//           "days": 0,
//           "enabled": false
//         }
//       }
//     ]
//   }
// },
resource "azurerm_monitor_diagnostic_setting" "audit" {
  name                       = "SQLSecurityAuditEvents"
  target_resource_id         = local.database_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  log {
    category = "DevOpsOperationsAudit"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
}

// {
//   "apiVersion": "2017-03-01-preview",
//   "type": "auditingSettings",
//   "name": "DefaultAuditingSettings",
//   "dependsOn": [
//     "[resourceId('Microsoft.Sql/servers/', parameters('sqlServerName'))]"
//   ],
//   "properties": {
//     "State": "Enabled",
//     "isAzureMonitorTargetEnabled": true
//   }
// },
resource "azurerm_mssql_database_extended_auditing_policy" "audit_master" {
  // depends_on             = [azurerm_mssql_server_extended_auditing_policy.example]
  database_id            = local.database_id
  log_monitoring_enabled = true
}

// {          
//   "condition": "[parameters('isMSDevOpsAuditEnabled')]",
//   "type": "devOpsAuditingSettings",
//   "apiVersion": "2020-08-01-preview",
//   "name": "Default",
//   "dependsOn": ["[parameters('sqlServerName')]"],
//   "properties": {
//     "State": "Enabled",
//     "isAzureMonitorTargetEnabled": true
//   }
// }
resource "azurerm_mssql_server_extended_auditing_policy" "example" {
  server_id              = azurerm_mssql_server.example.id
  log_monitoring_enabled = true
}

# TODO: This solution might be what the port is looking for but I'm getting a failure response from Azure when trying to deploy.
# I also tried creating the solution in the portal and importing it, but also getting an error there.
// resource "azurerm_log_analytics_solution" "insights" {
//   solution_name         = "SQLAuditing"
//   location              = azurerm_resource_group.example.location
//   resource_group_name   = azurerm_resource_group.example.name
//   workspace_resource_id = azurerm_log_analytics_workspace.logs.id
//   workspace_name        = azurerm_log_analytics_workspace.logs.name
//   tags                  = local.tags

//   plan {
//     publisher = "Microsoft"
//     product   = "OMSGallery/SQLAuditing"
//   }
// }

# This one is just a working example
// resource "azurerm_log_analytics_solution" "container-insights" {
//   solution_name         = "ContainerInsights"
//   location              = azurerm_resource_group.example.location
//   resource_group_name   = azurerm_resource_group.example.name
//   workspace_resource_id = azurerm_log_analytics_workspace.logs.id
//   workspace_name        = azurerm_log_analytics_workspace.logs.name
//   tags                  = local.tags

//   plan {
//     publisher = "Microsoft"
//     product   = "OMSGallery/ContainerInsights"
//   }
// }


// data "azurerm_client_config" "current" {}

// module "diagnostics" {
//   source                     = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=main"
//   log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

//   monitored_services = {
//     master = local.database_id
//     server = azurerm_mssql_server.example.id
//   }
// }



