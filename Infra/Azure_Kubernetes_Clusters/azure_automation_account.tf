# To manage an Azure Automation Account with Terraform, you primarily use the azurerm_automation_account resource from the AzureRM provider
# Basic Configuration Example - This snippet creates an Automation Account with a System-Assigned Managed Identity, which is the currently recommended authentication method.

#Key Automation Components

#Beyond the account itself, you can automate several sub-resources using Terraform: 

# Runbooks  : Use azurerm_automation_runbook to deploy PowerShell or Python scripts.
# Schedules : Use azurerm_automation_schedule to define when tasks should run.
# Variables : Securely store strings, booleans, or encrypted values with resources like azurerm_automation_variable_string.
# Modules   : Import necessary PowerShell modules using azurerm_automation_module.
# Webhooks  : Create external trigger endpoints for runbooks via azurerm_automation_webhook

#Best Practices
#Managed Identities : Avoid legacy "Run As" accounts (retired in late 2023) and use System-Assigned or User-Assigned Managed Identities for resource access.
#Source Control     : Use azurerm_automation_source_control to sync your runbooks directly from GitHub or Azure DevOps.
#Pricing            : While the service itself has a free tier, you are billed based on job runtime minutes

# Supported Location : [eastus, eastus2, westus, northeurope, southeastasia, japanwest]

resource "azurerm_automation_account" "automationaccount-DSCU" {
  name                = "automation-account-DSCU-00003"
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.rg-app-service.name
  sku_name            = "Basic"                        # Options: Basic, Free

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment    = "development"
    name           = "Azure_AIOPs_Team"
    Resource_owner = "harikrishnapalakila@deloiite.com"
    Team           = "Azure_Infrastructure_team"
    phone_Number   = "+917400215211"
    email_id       = "hapalakila@deloitte.com"
  }
}



# scheduling a specific PowerShell runbook...?
# To schedule a specific PowerShell runbook, you need to use three interconnected resources: the Runbook itself, a Schedule to define the timing, and a Job Schedule to link them together

# 1. Define the PowerShell Runbook
#Use the azurerm_automation_runbook resource. You can pull the script content from a local file to keep your Terraform code clean

# 1. Define the Runbook#
#resource "azurerm_automation_runbook" "example" {
#  name                    = "Daily-Cleanup-Runbook"
# ... (location, resource_group_name, automation_account_name, runbook_type, content)
#}

# 2. Create the Schedule (define frequency and start time)
#resource "azurerm_automation_schedule" "daily_6am" {
#  name                    = "run-every-day-6am"
# ... (resource_group_name, automation_account_name, frequency, start_time)
#}

# 3. Link Runbook to Schedule
#resource "azurerm_automation_job_schedule" "example_link" {
# ... (resource_group_name, automation_account_name, runbook_name, schedule_name)
#}


#Key Considerations
##Timezone: Defaults to UTC; specify if needed.
#Immutability: Changing names triggers new resource creation.
#DST: Handled automatically