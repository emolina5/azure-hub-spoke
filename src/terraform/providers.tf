terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.45.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfland-d-001"
    storage_account_name = "sttflandd001"                             # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tflandd"                                  # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "dev.terraform.tfstate"                    # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.\

    use_oidc             = true                                     # Can also be set via `ARM_USE_OIDC` environment variable.
    subscription_id      = "19da4f19-d6ac-43f4-ab9c-5c6cf0a8f2ea"   # Can also be set via `ARM_SUBSCRIPTION_ID` environment variable.
    tenant_id            = "46c655da-478c-4410-b3c8-cf9888ea56df"   # Can also be set via `ARM_TENANT_ID` environment variable.
    client_id            = "eb625440-7ac7-414e-bda6-a4b0419b9df4"   # Can also be set via `ARM_CLIENT_ID` environment variable.
  }
}

provider "azurerm" {
  #subscription_id = "19da4f19-d6ac-43f4-ab9c-5c6cf0a8f2ea"
  features {}
}
