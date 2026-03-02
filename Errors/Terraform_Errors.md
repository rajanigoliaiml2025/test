1. │ Error: a resource with the ID "/subscriptions/***/resourceGroups/RG-AI-Service-Resources" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_resource_group" for more information
│ 
│   with azurerm_resource_group.ai-services,
│   on Cognitive_Services_Deployment.tf line 2, in resource "azurerm_resource_group" "ai-services":
│    2: resource "azurerm_resource_group" "ai-services" {
│ 
╵
╷
│ Error: a resource with the ID "/subscriptions/***/resourceGroups/RG-DSCU-SecCluster-03" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_resource_group" for more information
│ 
│   with azurerm_resource_group.rg,
│   on main.tf line 2, in resource "azurerm_resource_group" "rg":
│    2: resource "azurerm_resource_group" "rg" {



2. ╷
│ Error: creating Account (Subscription: "***"
│ Resource Group Name: "RG-AI-Service-Resources"
│ Account Name: "oai-service-account"): performing AccountsCreate: unexpected status 409 (409 Conflict) with error: FlagMustBeSetForRestore: An existing resource with ID '/subscriptions/***/resourceGroups/RG-AI-Service-Resources/providers/Microsoft.CognitiveServices/accounts/oai-service-account' has been soft-deleted. To restore the resource, you must specify 'restore' to be 'true' in the property. If you don't want to restore existing resource, please purge it first.
│ 
│   with azurerm_cognitive_account.ai-service-OpenAI,
│   on Cognitive_Services_Deployment.tf line 8, in resource "azurerm_cognitive_account" "ai-service-OpenAI":
│    8: resource "azurerm_cognitive_account" "ai-service-OpenAI" {

3. 
╷
│ Error: creating Account (Subscription: "***"
│ Resource Group Name: "RG-AI-Service-Resources"
│ Account Name: "oai-service-account"): performing AccountsCreate: unexpected status 409 (409 Conflict) with error: FlagMustBeSetForRestore: An existing resource with ID '/subscriptions/***/resourceGroups/RG-AI-Service-Resources/providers/Microsoft.CognitiveServices/accounts/oai-service-account' has been soft-deleted. To restore the resource, you must specify 'restore' to be 'true' in the property. If you don't want to restore existing resource, please purge it first.
│ 
│   with azurerm_cognitive_account.ai-service-OpenAI,
│   on Cognitive_Services_Deployment.tf line 8, in resource "azurerm_cognitive_account" "ai-service-OpenAI":
│    8: resource "azurerm_cognitive_account" "ai-service-OpenAI" {
│ 

4. AI Issues

╷
│ Error: creating Account (Subscription: "***"
│ Resource Group Name: "RG-AI-Service-Resources"
│ Account Name: "oai-service-account-01"): performing AccountsCreate: unexpected status 400 (400 Bad Request) with error: InsufficientQuota: Insufficient quota. Cannot create/update/move resource 'oai-service-account-01'.
│ 
│   with azurerm_cognitive_account.ai-service-OpenAIs,
│   on Cognitive_Services_Deployment.tf line 8, in resource "azurerm_cognitive_account" "ai-service-OpenAIs":
│    8: resource "azurerm_cognitive_account" "ai-service-OpenAIs" {
│ 