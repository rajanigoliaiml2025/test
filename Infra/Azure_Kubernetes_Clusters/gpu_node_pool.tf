# 1. Define the GPU Node Pool - In your Terraform configuration, use the azurerm_kubernetes_cluster_node_pool resource to add a specialized pool for GPU workloads. It is a best practice to keep your default_node_pool for system services and use a separate pool for GPUs. 

resource "azurerm_kubernetes_cluster_node_pool" "gpu_pool" {
  name                  = "gpunodepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
   # NC, ND, NV ---> GPU --
  vm_size               = "Standard_NC6s_v3" # Example GPU-enabled SKU  - Compute & AI Training (NC-Series) - Standard_NC6s_v3, Standard_NC24rs_v3 (NVIDIA Tesla V100), NCads_H100_v - (NVIDIA H100) for high-end Applied AI and batch inference.
  node_count            = 1
  #enable_auto_scaling   = true
  auto_scaling_enabled = true
  min_count             = 1
  max_count             = 3

  # Managed NVIDIA Drivers: Set gpu_driver_enabled = true (or use the --gpu-driver flag in CLI equivalents) to let AKS manage driver installation.
  #gpu_driver_enabled = true
  gpu_driver = "Install"

  node_labels = {
    "accelerator" = "nvidia"
  }

  # Taints prevent non-GPU pods from scheduling here
  node_taints = [
    "sku=gpu:NoSchedule"

  ]
}
