# ############ Efficient Multi-Model deployment # #############

#  Create a Resource Group for AI-Services i.e. Cognitive Services 
##resource "azurerm_resource_group" "ai-services" {
#  name     = "RG-AI-Service-Resources"
#  location = "East US2"
#}

# 1. Define the OpenAI Account
#resource "azurerm_cognitive_account" "ai-service-openai-account" {
#  name                = "ai-service-openai-service-account"
#   location            = azurerm_resource_group.ai-services.location
#  resource_group_name = azurerm_resource_group.ai-services.name
#  kind                = "OpenAI"
#  sku_name            = "S0"
#}


# 2. Define the Models to Deploy
locals {
  openai_models = {
    "gpt-4-o" = {
      model_format  = "OpenAI"
      model_name    = "gpt-4o"
      model_version = "2024-05-13"
      capacity      = 10
    },
    "gpt-4o-mini" = {
      model_format  = "OpenAI"
      model_name    = "gpt-4o-mini"
      model_version = "2024-07-18" # Change from 0125  - "0125"  # Update from "0613"
      capacity      = 20
    }
  }
}


# 3. Create Multiple Deployments using a Loop
resource "azurerm_cognitive_deployment" "models" {
  for_each             = local.openai_models
  name                 = each.key
  #cognitive_account_id = azurerm_cognitive_account.ai-service-openai-account.id
  cognitive_account_id = azurerm_cognitive_account.ai-service-OpenAIs.id

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = "Standard"
    capacity = each.value.capacity
  }
}
