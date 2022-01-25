resource "azurerm_resource_group" "example" {
  name     = "rg-${local.project}"
  location = "centralus"
  tags     = local.tags
}

resource "azurerm_role_assignment" "sql_audit" {
  principal_id         = azurerm_mssql_server.example.identity.0.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_resource_group.example.id
}