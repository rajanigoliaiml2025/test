# Infra_configuration_using_Ansible

1. The combination of Terraform, Azure Kubernetes Service (AKS), and Ansible creates a powerful end-to-end automation workflow for cloud infrastructure. In this paradigm, Terraform "builds the stage" by provisioning the cluster, while Ansible "sets the scene" by configuring the software and applications within it.

2. Role of Each Tool

Terraform (Infrastructure Provisioning): 
Best for "Day 0" activities.

It uses a declarative approach to create and manage the lifecycle of Azure resources like AKS clusters, virtual networks, and resource groups.

Ansible (Configuration Management): 
Best for "Day 1 and beyond." 

It is agentless and procedural, ideal for configuring Kubernetes objects (pods, services), deploying applications, and patching systems once the infrastructure is live

3. Integration Patterns
Successfully linking these tools requires a handoff strategy for the AKS cluster's credentials and state:

Terraform Provisioners (local-exec): Terraform can automatically trigger an Ansible playbook immediately after the AKS cluster is created.
This is simple but tightly couples the two tools.

Dynamic Inventory: Ansible can use dynamic inventory plugins to read the Terraform state file. This allows Ansible to automatically discover the newly created AKS cluster's endpoint and credentials.

CI/CD Orchestration: The most robust approach for enterprise use. Tools like GitHub Actions or Azure DevOps run Terraform in one stage and Ansible in the next, passing the cluster's kubeconfig between them

# ############  Typical Use Case: Production aks ########################
Terraform: Provisions a production-ready AKS cluster with auto-scaling, monitoring via Log Analytics, and integrated Azure Key Vault for secrets.
Ansible  : Configures the cluster by installing an istio/Nginx Ingress Controller, setting up Cert-Manager for SSL certificates, and deploying the microservices application etc..

# ############ Terraform block for an AKS cluster or a specific Ansible playbook for Kubernetes configuration #################

Here are the configuration blocks for provisioning an AKS cluster with Terraform and deploying applications with Ansible.

1. Terraform: Provisioning the AKS Cluster
 This block uses the azurerm_kubernetes_cluster resource to create a basic managed cluster in Azure. 

 resource "azurerm_kubernets_cluster" "genai_aks_cluster" {
  name      = "genai_aks_cluster"
  lcoation = "southcentralus"
  dnsprefix = "wellsforgogenaiakscluster"
  resource_group = "rg-genai"
  private_cluster_enabled = true
  
  default_pool_name {
    count = 5
    size = "Standard_D2_v2"
    subnet_id = azurerm_subnet.aks_subnet.id
  }
  tags = {
    Environents = "Dev"
  }

 }

2. Ansible: Deploying a Kubernetes Service
This section discusses an Ansible playbook that utilizes the kubernetes.core.k8s module to deploy an Nginx application, assuming the Kubernetes Collection is installed.
------------------------------------------------

nginx_app_deployment.yml
 

---
- name: Deploy Application to AKS
  hosts: localhost
  connection: local
  tasks:
    - name: Create a Namespace
      kubernetes.core.k8s:
        name: my-app-ns
        kind: Namespace
        state: present

    - name: Deploy Nginx Deployment
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: nginx-deployment
            namespace: my-app-ns
          spec:
            replicas: 2
            selector:
              matchLabels:
                app: nginx
            template:
              metadata:
                labels:
                  app: nginx
              spec:
                containers:
                - name: nginx
                  image: nginx:1.25
                  ports:
                  - containerPort: 80

    - name: Create LoadBalancer Service
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: nginx-service
            namespace: my-app-ns
          spec:
            type: LoadBalancer
            selector:
              app: nginx
            ports:
            - protocol: TCP
              port: 80
              targetPort: 80

----------------

Key Integration Tips

1. Authentication: Ansible typically looks for a kubeconfig file at ~/.kube/config. 
   Use the Azure CLI command : az aks get-credentials --resource-group ai-rg --name aks-wellsforgo-dev-seccluster-00001 to merge the new cluster credentials into your local config after running Terraform.

   Requirements: To use the Ansible k8s module, install the OpenShift and Kubernetes Python clients (pip install kubernetes openshift) on your control machine.


-------------------

#  ########## Terraform local-exec provisioner to trigger this Ansible playbook automatically after the cluster is built ##########
 
 To trigger your Ansible playbook automatically after the AKS cluster is provisioned, 
 use a Terraform null_resource (or terraform_data for versions 1.4+) with a local-exec provisioner. 
 This resource is configured to wait for the cluster's completion before executing the Ansible command on your local machine.

 Terraform Integration Block
 Add this block to your Terraform configuration. 
 It ensures that the Ansible playbook only runs once the AKS cluster is fully healthy. 



 resource "null_resource" "run_ansible" {
  # Ensures this runs only AFTER the AKS cluster is successfully created
  depends_on = [azurerm_kubernetes_cluster.aks]

  # Optional: Re-run if the cluster ID changes
  triggers = {
    cluster_id = azurerm_kubernetes_cluster.aks.id
  }

  provisioner "local-exec" {
    # 1. Fetch cluster credentials for kubectl
    # 2. Run the Ansible playbook
    command = <<EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.example.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing
      ansible-playbook -i localhost, nginx_app_deployment.yml
    EOT
  }
}



-----------

Key Components
depends_on: Crucial for defining the execution order; it prevents Ansible from starting before the AKS resource is ready.
az aks get-credentials: Since Ansible’s Kubernetes modules usually rely on a local kubeconfig, this command ensures your local environment is authenticated to the new cluster.
triggers: By mapping this to the cluster's ID, you ensure that if you ever destroy and recreate the cluster, the Ansible configuration will trigger again.


-------------
Implementation Advice
Sequential Steps: If your playbook requires specific outputs (like a LoadBalancer IP), ensure those are exported as Terraform outputs and passed to Ansible via extra variables (-e "lb_ip=${terraform_output_name}").
Warning on Reliability: Provisioners are "brittle" because Terraform cannot track the internal state of the Ansible run. For production environments, it is often better to use a CI/CD pipeline (like GitHub Actions or Azure DevOps) to run Terraform and Ansible as separate, sequential stages.


# ################# dynamic inventory options that read your Terraform state directly instead of hardcoding resource names #############

To avoid hardcoding resource names, you can use Ansible Inventory Plugins that read your Terraform state file directly. This creates a "source of truth" where any resource created by Terraform is automatically discoverable by Ansible.


Option 1: Official cloud.terraform.terraform_provider Plugin 
The Red Hat Certified Cloud Terraform Collection provides a robust plugin that parses .tfstate files to build an inventory


1. Installation
Install the collection on your control machine:

ansible-galaxy collection install cloud.terraform


2. Configuration File (inventory.yml)
Create a YAML file ending in terraform_state.[yml|yaml] or terraform_provider.[yml|yaml].

plugin: cloud.terraform.terraform_provider
project_path: ./path/to/terraform/project
# Optional: defaults to terraform.tfstate if not specified
state_file: terraform.tfstate 

3. Enable the Plugin
In your ansible.cfg, ensure the plugin is enabled:

[inventory]
enable_plugins = cloud.terraform.terraform_provider



# ###############  Option 2: terraform_state Plugin #########
This older but widely used plugin works by using the terraform show command under the hood to parse state data. 
Ansible Galaxy
Ansible Galaxy
Setup: Similar to the provider plugin, create a file (e.g., my_aks.terraform_state.yml).
Best Use: This is ideal for multi-cloud setups as it supports state files from AWS, Azure, and GCP.


Option 3: Custom Python Script (Classic Method)
If you need highly specific logic, you can use a Python script that calls terraform output -json and transforms the data into the JSON format Ansible expects.


# ############## Comparison of Methods #########
Method 	Best For	Pros	Cons
Inventory Plugin	Complex environments	Clean decoupling; always reflects current state.	Requires plugin setup and collection installation.
Local-Exec	Simple/Dev setups	No extra plugins; triggers immediately after provisioning.	Tightly coupled; harder to manage in enterprise pipelines.
CI/CD Pipeline	Enterprise Production	Maximum decoupling; independent tool execution.	Relies on external orchestration (e.g., GitHub Actions).


# ##########   inventory configuration that specifically groups your AKS nodes by their Azure tags ############

To group AKS nodes by their Azure tags, you move away from reading the Terraform state and instead use the Azure Resource Manager (ARM) dynamic inventory plugin. Since AKS nodes are actually Virtual Machines within a hidden "Node Resource Group," this is the most reliable way to target them.


1. Configure the Azure Inventory Plugin
Create a file named aks_inventory.azure_rm.yaml. The keyed_groups section is the "magic" that automatically creates Ansible groups based on your Azure tags.


plugin: azure.microsoft.azure.azure_rm
include_vm_resource_groups:
  - "MC_myResourceGroup_myAKSCluster_eastus" # The auto-generated Node Resource Group
auth_source: cli # Uses your 'az login' credentials

# Grouping logic
keyed_groups:
  - prefix: tag
    key: tags


2. Enable the Plugin
Ensure your ansible.cfg is set up to allow the Azure RM plugin:

[inventory]
enable_plugins = azure.microsoft.azure.azure_rm

3. How to use it in your Playbook
If you tagged your AKS nodes in Terraform with environment: production, the plugin creates a group named tag_environment_production.

- name: Configure Production Nodes
  hosts: tag_environment_production
  tasks:
    - name: Ensure a specific monitoring agent is present
      ansible.builtin.package:
        name: htop
        state: present

Pro-Tip: Finding the "Node Resource Group"
Terraform creates the AKS cluster in your specified Resource Group, but the nodes live in a separate, auto-generated group (usually prefixed with MC_). You can capture this name in Terraform to pass it to Ansible:

# In your Terraform outputs.tf
output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}
Prerequisites
To use this, you'll need the Azure Collection for Ansible and the required Python libraries:
ansible-galaxy collection install azure.azcollection
pip install 'ansible[azure]'


# ####### mapping the Terraform tags to the AKS default_node_pool block to ensure the nodes actually inherit them ############

To ensure your AKS nodes inherit Azure tags from Terraform, you must define the tags argument directly inside the default_node_pool block.
While setting tags at the top level of the azurerm_kubernetes_cluster resource labels the cluster itself, it does not automatically propagate those tags to the underlying Virtual Machine Scale Set (VMSS) or individual nodes. 


Terraform Configuration Example
This example shows how to correctly map tags to the initial node pool.


resource "azurerm_kubernetes_cluster" "example" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "myaks"

  # These tags apply ONLY to the AKS Cluster resource itself
  tags = {
    Environment = "Production"
  }

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"

    # CRITICAL: These tags apply to the VMSS and individual nodes
    tags = {
      Environment = "Production"
      Project     = "Automation"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}



Key Considerations
Cluster vs. Node Pool Tags: Tags on the AKS cluster resource apply to all resources related to the cluster except the node pools. You must explicitly define them in each node pool block to ensure full visibility in Azure Cost Management.
Node Labels vs. Tags: Do not confuse tags (Azure-level metadata) with node_labels (Kubernetes-level metadata). Use node_labels inside the same block if you need to target pods to specific nodes using nodeSelector.
Updating Tags: Modifying tags in the default_node_pool block can sometimes trigger a node pool update or replacement depending on your provider version; always check the terraform plan output carefully.
Additional Node Pools: If you add extra pools using the azurerm_kubernetes_cluster_node_pool resource, you must also define a tags block within that specific resource.

