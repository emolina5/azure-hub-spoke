terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.45.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  subscription_id = "19da4f19-d6ac-43f4-ab9c-5c6cf0a8f2ea"
  features {}
}
