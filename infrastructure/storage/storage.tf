resource "azurerm_storage_account" "audits" {
  access_tier               = "Cool"
  account_kind              = "StorageV2"
  account_replication_type  = "GRS"
  account_tier              = "Standard"
  allow_blob_public_access  = false
  enable_https_traffic_only = true
  is_hns_enabled            = false
  large_file_share_enabled  = false
  location                  = azurerm_resource_group.example.location
  min_tls_version           = "TLS1_2"
  name                      = substr(replace("sa-${local.project}-${random_pet.fido.id}", "-", ""), 0, 24)
  resource_group_name       = azurerm_resource_group.example.name
  tags                      = local.tags

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    bypass = [
      "AzureServices",
    ]
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}
