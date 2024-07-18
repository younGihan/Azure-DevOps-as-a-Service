terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Local Backend for testing
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# # Azure Backend
# terraform {
#   backend "azurerm" {
#     resource_group_name  = var.rg_name
#     storage_account_name = var.storage_account_name
#     container_name       = var.container_name
#     key                  = "${var.key_prefix}.${uuid}.terraform.tfstate"
#   }
# }

# via AD auth
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "StorageAccount-ResourceGroup"  # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
#     storage_account_name = "abcd1234"                      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
#     container_name       = "tfstate"                       # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
#     key                  = "prod.terraform.tfstate"        # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
#     use_azuread_auth     = true                            # Can also be set via `ARM_USE_AZUREAD` environment variable.
#   }
# }

# via AD SPN or UAM OICD
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "StorageAccount-ResourceGroup"          # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
#     storage_account_name = "abcd1234"                              # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
#     container_name       = "tfstate"                               # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
#     key                  = "prod.terraform.tfstate"                # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
#     use_oidc             = true                                    # Can also be set via `ARM_USE_OIDC` environment variable.
#     client_id            = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_CLIENT_ID` environment variable.
#     subscription_id      = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_SUBSCRIPTION_ID` environment variable.
#     tenant_id            = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_TENANT_ID` environment variable.
#   }
# }
