resource "azurerm_log_analytics_workspace" "logs" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "${local.project}-${random_pet.fido.id}"
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = local.tags
}