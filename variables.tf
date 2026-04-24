# ============================================================
# Root Terraform Variables
# IBM Cloud OpenShift ROKS Cluster 4.18 + Transit Gateway
# ============================================================


# ============================================================
# IBM Cloud Variables
# ============================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region for cluster resources"
  type        = string
  default     = "ca-tor"
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud Resource Group name (leave empty to use account default)"
  type        = string
  default     = "default"
}

# ============================================================
# Feature Flags
# ============================================================

variable "create_roks_cluster" {
  description = "Create OpenShift ROKS cluster"
  type        = bool
  default     = true
}

variable "create_roks_transit_gateway" {
  description = "Create Transit Gateway and VPC connections"
  type        = bool
  default     = true
}

variable "create_roks_registry_cos_instance" {
  description = "Create Cloud Object Storage instance for OpenShift registry"
  type        = bool
  default     = true
}

# ============================================================
# Cluster Variables
# ============================================================

variable "roks_cluster_vpc_name" {
  description = "Name of the cluster VPC"
  type        = string
  default     = "tf-cluster-vpc"
}

variable "openshift_cluster_name" {
  description = "Name of the OpenShift cluster"
  type        = string
  default     = "tf-openshift-cluster"
}

variable "openshift_cluster_version" {
  description = "OpenShift cluster version (e.g. 4.18). If empty, the latest available version is used."
  type        = string
  default     = "4.18"
}

variable "roks_workers_per_zone" {
  description = "Number of worker nodes per zone"
  type        = number
  default     = 1
}

variable "roks_min_worker_vcpu_count" {
  description = "Minimum vCPU count for worker nodes (used for auto-selecting flavor)"
  type        = number
  default     = 16
}

variable "roks_min_worker_memory_gb" {
  description = "Minimum memory in GB for worker nodes (used for auto-selecting flavor)"
  type        = number
  default     = 64
}

variable "roks_cos_instance_name" {
  description = "Name of the COS instance for OpenShift registry (defaults to cluster_name-cos)"
  type        = string
  default     = "tf-openshift-cos-instance"
}

# ============================================================
# Transit Gateway Variables
# ============================================================

variable "roks_transit_gateway_name" {
  description = "Name of the Transit Gateway"
  type        = string
  default     = "tf-tgw"
}

