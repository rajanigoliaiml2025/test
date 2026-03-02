# ############### Security AKS Cluster Provision for US Regions for Well-Forgo Client ##############

# 1. Minimal Terraform Configuration 
Create a file named main.tf with the following basic structure to provision a cluster

2. Deployment Workflow
Execute these standard Terraform commands in your terminal: 

terraform init: Initializes the working directory and downloads the AzureRM provider.
terraform plan: Previews the changes to your Azure infrastructure without applying them.
terraform apply: Executes the plan to create the AKS cluster.
terraform destroy: Removes all resources created by the configuration.

3. Key Configuration Options
Authentication: Terraform typically uses the Azure CLI for local authentication via az login.
Identity: Using SystemAssigned (as shown above) allows Azure to manage the cluster's identity automatically, eliminating the need for manual Service Principal credentials.
Node Pools: You can add additional worker node pools using the azurerm_kubernetes_cluster_node_pool resource if you need specialized hardware (e.g., GPU nodes).
Modules: For production, Microsoft recommends using the official Azure AKS Terraform Module, which includes built-in defaults for networking and monitoring

4. Post-Deployment Access
Once deployed, retrieve your credentials to interact with the cluster using kubectl:

az aks get-credentials --resource-group RG-AKS-Wells-Fargo-Dev-SCU-SecurityCluster-00001 --name AKS-Wells-Fargo-Dev-SCU-SecurityCluster-00001
kubectl get nodes


# ##########################  private networking or Azure AD integration ##########################


To transition from a basic setup to a production-ready Private AKS Cluster with Microsoft Entra ID (Azure AD) integration, you need to modify the networking and access control profiles within your azurerm_kubernetes_cluster resource.

1. Private Networking (Private Cluster)
    A private cluster ensures that communication between the API server and node pools remains on a private network, and the API server endpoint is not exposed to the public internet. 

private_cluster_enabled: Set to true to ensure the API server has no public IP.
Azure CNI: Use the advanced azure network plugin so pods get real IP addresses from your VNet.
Connectivity: Since the API is private, you must manage the cluster via a Jumpbox VM, Azure Bastion, or a VPN/ExpressRoute connected to the VNet. 

2. Microsoft Entra ID (Azure AD) Integration 
Replacing local Kubernetes accounts with Entra ID allows you to use Azure RBAC for cluster access, centralizing identity management. 

azure_active_directory_role_based_access_control: This block enables the integration.
azure_rbac_enabled: When set to true, you can use standard Azure Role Assignments (like "Azure Kubernetes Service RBAC Cluster Admin") to manage permissions instead of manual Kubernetes RoleBindings.


3. Advanced Terraform Example
This configuration combines private networking with Entra ID RBAC:


# #############################

The following Terraform configuration combines Private Networking (VNet integration and private API server) with Azure AD (Entra ID) managed integration. 

 A sample Terraform configuration for this setup includes defining a virtual network and subnet, and then creating an Azure Kubernetes Service (AKS) cluster. 
 The AKS cluster resource configuration specifies private_cluster_enabled = true for private networking and
 utilizes a network_profile with network_plugin = "azure" and connects nodes to the VNet subnet ID in the default_node_pool. 
 
 Azure AD integration is configured using the azure_active_directory_role_based_access_control block with managed = true and azure_rbac_enabled = true, allowing the specification of admin group object IDs.
  Due to the private nature of the cluster, access requires connecting from within the same or a peered VNet, potentially using a Jumpbox VM or Azure Bastion