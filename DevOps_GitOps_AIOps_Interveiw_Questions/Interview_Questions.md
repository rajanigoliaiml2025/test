# Terraform Interview Setup - Questions

1. Error: Inconsistent dependency lock file

The following dependency selections recorded in the lock file are
inconsistent with the current configuration:
  - provider registry.terraform.io/hashicorp/azurerm: required by this configuration but no version is selected

To make the initial dependency selections that will initialize the dependency
lock file, run:
  terraform init


2. unable to build authorizer for Resource Manager API: could not configure AzureCli Authorizer: tenant ID was not specified and the default tenant ID could not be determined: obtaining tenant ID: obtaining account details: running Azure CLI: exit status 1: ERROR: Please run 'az login' to setup account.

Solution:

For CI/CD, it is highly recommended to use Service Account or Service Principals or Managed Identities by setting the following environment variables instead of relying on az login:

3. Terraform issues and Error - questions
╷
│ Error: creating Account (Subscription: "***"
│ Resource Group Name: "RG-AI-Service-Resources"
│ Account Name: "oai-service-account"): performing AccountsCreate: unexpected status 409 (409 Conflict) with error: FlagMustBeSetForRestore: An existing resource with ID '/subscriptions/***/resourceGroups/RG-AI-Service-Resources/providers/Microsoft.CognitiveServices/accounts/oai-service-account' has been soft-deleted. To restore the resource, you must specify 'restore' to be 'true' in the property. If you don't want to restore existing resource, please purge it first.
│ 
│   with azurerm_cognitive_account.ai-service-OpenAI,
│   on Cognitive_Services_Deployment.tf line 8, in resource "azurerm_cognitive_account" "ai-service-OpenAI":
│    8: resource "azurerm_cognitive_account" "ai-service-OpenAI" {



