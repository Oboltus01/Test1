terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.77"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-roman-tfstate"
    storage_account_name = "tfstateoboltus012079"
    container_name       = "tfstate"
    key                  = "test1.terraform.tfstate"

    use_cli          = true
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  # Configuration options
}