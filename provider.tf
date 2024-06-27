#terraform {
#    required_providers {
#        azurerm = {
#            source = "hasicorp/azurerm"
#            version = "3.15.0"
#        }
#    }
#}

provider "azurerm" {
  subscription_id = "676a27d5-80ee-48ec-9fcb-514e64cb5d50"
  client_id       = "c01ab38b-bc9e-4622-bdfa-271489dc74b7"
  client_secret   = "Vj78Q~L7L50E9UiCQpEYP0U3zyEFsOxx47OmFa6Z"
  tenant_id       = "577ce577-d158-4cea-9fd3-02848fb9369a"
  features {

  }
  skip_provider_registration = true
}
