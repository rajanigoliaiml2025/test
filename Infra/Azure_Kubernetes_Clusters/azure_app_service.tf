# Create a Resource Group for SouthCentralUS location for SecurityCluster
resource "azurerm_resource_group" "rg-app-service" {
  name     = "RG-DSCU-app-service-00003"
  location = "SouthCentralUS"
  tags = {
    name           = "Azure_AIOPs_Team"
    Resource_owner = "harikrishnapalakila@deloiite.com"
    Team           = "Azure_Infrastructure_team"
    phone_Number   = "+917400215211"
    email_id       = "hapalakila@deloitte.com"
  }
}

# App Service Plan: Defines the underlying VM's region, scale, and pricing tier (e.g., S1, P1v2) using azurerm_service_plan

resource "azurerm_service_plan" "APPSVCPLAN" {
  name                = "app-svc-plan-DSCU-00003"
  resource_group_name = azurerm_resource_group.rg-app-service.name
  location            = azurerm_resource_group.rg-app-service.location
  os_type             = "Linux"                           # Can be Linux, Windows, or WindowsContainer
  sku_name            = "S1"                            # Example SKU; common options: B1, S1, P1v2, etc.
}


#Web App: The actual hosting environment, defined as either azurerm_linux_web_app or azurerm_windows_web_app

resource "azurerm_linux_web_app" "example" {
  name                = "webapp-linux-DSCU-00003"
  resource_group_name = azurerm_resource_group.rg-app-service.name
  location            = azurerm_resource_group.rg-app-service.location
  service_plan_id     = azurerm_service_plan.APPSVCPLAN.id

  site_config {
    application_stack {
      python_version       = "3.12"               # Define your Python version here - Supported: 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13
      #node_version        = "18-lts"             # Example for Node.js
      #java_version        = "17"                 # Options: 8, 11, 17, 21
      #java_server         = "JAVA"               # Standard Java SE stack
      #java_server_version = "SE"                 # Required for Java SE
      #current_stack = "dotnet"
      #dotnet_version = "v8.0" 
    }
    # Optional: Custom startup command (e.g., for Gunicorn)
    app_command_line = "gunicorn --bind=0.0.0.0 --timeout 600 app:app"
  }

  # app_settings for environment variables. Environment variables are defined as a map of key-value pairs at the top level of the resource.
   app_settings = {
    "PYTHON_ENV"         = "production"
    "DATABASE_URL"       = "postgresql://user:pass@db:5432/dbname"
    "CUSTOM_VARIABLE"    = "my-value"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true" # Enables automation for pip install
  }

  #Accessing Variables in Python - Once deployed, these settings are available via the standard os.environ module in your Python code

# import os
#  db_url = os.environ.get('DATABASE_URL')
#  env = os.environ.get('PYTHON_ENV', 'development')

}