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

resource "azurerm_mssql_server_extended_auditing_policy" "example" {
  depends_on = [ azurerm_role_assignment.sql_audit ]
  server_id         = azurerm_mssql_server.example.id
  storage_endpoint  = azurerm_storage_account.audits.primary_blob_endpoint
  retention_in_days = 6
}