#
# Kubernetes Cluster
#

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix                = var.name
  sku_tier                  = "Standard"
  automatic_upgrade_channel = "patch"
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  default_node_pool {
    name                        = "nodepool1"
    vm_size                     = "standard_d4ds_v5"
    os_disk_type                = "Ephemeral"
    temporary_name_for_rotation = "nodepool"
    node_count                  = 3
    zones                       = ["1", "2", "3"]

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

#
# Role Assignment
#

resource "azurerm_role_assignment" "main" {
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = var.registry_id
}
