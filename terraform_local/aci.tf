resource "azurerm_resource_group" "aci_rg" {
  name     = "rg-hellogo-aci"
  location = "eastus"
  tags     = var.tags
}

resource "azurerm_container_group" "hellogo" {
  name                = "aci-hellogo"
  location            = azurerm_resource_group.aci_rg.location
  resource_group_name = azurerm_resource_group.aci_rg.name
  ip_address_type     = "Public"
  dns_name_label      = "hellogo-${var.tags["owner"] == "demo owner" ? "demo" : var.tags["owner"]}"
  os_type             = "Linux"
  tags                = var.tags

  #   image_registry_credential {
  #     server   = "ghcr.io"
  #     username = var.ghcr_username
  #     password = var.ghcr_token
  #   }

  container {
    name   = "hellogo"
    image  = "ghcr.io/borisovcloud/devops2079/hellogo:${var.image_tag}"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }
}

output "hellogo_url" {
  value       = "http://${azurerm_container_group.hellogo.fqdn}:8080"
  description = "URL to access the hellogo application"
}
