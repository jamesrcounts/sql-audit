resource "azurerm_resource_group" "example" {
  name     = "rg-${random_pet.fido.id}"
  location = "centralus"
  tags     = local.tags
}