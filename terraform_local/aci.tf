data "azurerm_resource_group" "aci_rg" {
  name = "rg-roman-test1-aci"
}

resource "azurerm_container_group" "hellogo" {
  name                = "aci-roman-test1"
  location            = data.azurerm_resource_group.aci_rg.location
  resource_group_name = data.azurerm_resource_group.aci_rg.name
  ip_address_type     = "Public"
  dns_name_label      = "roman-test1-2079"
  os_type             = "Linux"
  restart_policy      = "Always"
  tags                = var.tags

  container {
    name   = "hellogo"
    image  = "ghcr.io/oboltus01/test1/hellogo:${var.image_tag}"
    cpu    = 0.5
    memory = 0.5

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }
}

output "hellogo_url" {
  description = "Public URL of the hellogo application"
  value       = "http://${azurerm_container_group.hellogo.fqdn}:8080"
}