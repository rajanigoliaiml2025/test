#  Create a Resource Group for AI-Services i.e. Cognitive Services 
resource "azurerm_resource_group" "ai-services" {
  name     = "RG-AI-Service-Resources"
  location = "East US"
}

#  Cognitive Services Account (e.g., for OpenAI) - to hold all AI-Services 
resource "azurerm_cognitive_account" "ai-service-OpenAI" {
  name                = "oai-service-account"
  location            = azurerm_resource_group.ai-services.location
  resource_group_name = azurerm_resource_group.ai-services.name
  kind                = "OpenAI"                             # Options: AIServices, SpeechServices, etc.
  sku_name            = "S0"
}

# 3. Model Deployment
resource "azurerm_cognitive_deployment" "oai-model-deployment" {
  name                 = "gpt-4-deployment"
  cognitive_account_id = azurerm_cognitive_account.ai-service-OpenAI.id
  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = "0613"
  }
  sku {
    name = "Standard"
  }
}
