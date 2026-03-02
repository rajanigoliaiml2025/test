#  Create a Resource Group for AI-Services i.e. Cognitive Services 
resource "azurerm_resource_group" "ai-services" {
  name     = "RG-AI-Service-Resources"
  location = "East US2"
}

#  Cognitive Services Account (e.g., for OpenAI) - to hold all AI-Services 
resource "azurerm_cognitive_account" "ai-service-OpenAIs" {
  name                = "oai-service-account-01"
  location            = azurerm_resource_group.ai-services.location
  resource_group_name = azurerm_resource_group.ai-services.name
  kind                = "OpenAI"                             # Options: AIServices, SpeechServices, etc.
  sku_name            = "S0"
}

####
# 3. Model Deployment
resource "azurerm_cognitive_deployment" "oai-model-deployment-01" {
  name                 = "gpt-4-deployment-01"
  cognitive_account_id = azurerm_cognitive_account.ai-service-OpenAIs.id
  model {
    format  = "OpenAI"
    name    = "gpt-4o"   # Error: ServiceModelDeprecated for GPT-4 model ---
    version = "2024-11-20"
  }
  sku {
    name = "Standard"
  }
}


#Current Model Status (as of Feb 2026)
#Model 	  Version	    Status	Retirement Date
#GPT-4	  0613	      Retired	June 6, 2025
#GPT-4o	  2024-11-20	GA	    Oct 1, 2026 --> RL, TPL, TRL,TPL 
#GPT-4.1	2025-04-14	GA	    Oct 14, 2026
