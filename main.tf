# ============================================================
# Root Terraform Configuration
# IBM Cloud OpenShift ROKS Cluster 4.18 + Transit Gateway
# ============================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
    }
  }
}

module "cluster" {
  source = "./modules/cluster"

  # IBM Cloud Configuration
  ibmcloud_api_key = var.ibmcloud_api_key
  cluster_region   = var.ibmcloud_cluster_region
  resource_group   = var.ibmcloud_resource_group

  # Feature Flags
  create_cluster         = var.create_cluster
  create_transit_gateway = var.create_transit_gateway
  create_cos_instance    = var.create_cos_instance

  # Cluster VPC Configuration
  cluster_vpc_name = var.cluster_vpc_name

  # Transit Gateway Configuration
  transit_gateway_name = var.transit_gateway_name

  # Cloud Object Storage Configuration
  cos_instance_name = var.cos_instance_name

  # OpenShift Cluster Configuration
  openshift_cluster_name    = var.openshift_cluster_name
  openshift_cluster_version = var.openshift_cluster_version
  workers_per_zone          = var.workers_per_zone
  min_worker_vcpu_count     = var.min_worker_vcpu_count
  min_worker_memory_gb      = var.min_worker_memory_gb
}
