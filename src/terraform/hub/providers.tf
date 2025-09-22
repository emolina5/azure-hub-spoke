terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.45.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfland-d-01"
    storage_account_name = "sttflandd01"          # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tflandd"               # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "hub.terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.\
  }
}

provider "azurerm" {
  subscription_id = "19da4f19-d6ac-43f4-ab9c-5c6cf0a8f2ea"
  features {}
}
