# IBM Cloud OpenShift ROKS 4.18 Cluster for BIG-IP Next for Kubernetes

## About This Workspace

This Schematics-ready Terraform workspace provisions the IBM Cloud infrastructure required to run BIG-IP Next for Kubernetes on an IBM Cloud OpenShift ROKS 4.18 cluster. It creates the VPC, subnets, public gateways, COS instance, OpenShift cluster, and Transit Gateway needed to support BIG-IP Next for Kubernetes ingress and egress traffic flows.

## Deploying with IBM Schematics

The following IBM provider and IAM variables must be defined.

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `ibmcloud_api_key` | API Key used to authorize all deployment resources. | REQUIRED | `0q7N3CzUn6oKxEsr7fLc1mxkukBeAEcsjNRQOg1kdDSY` (note: not a real API key) |
| `ibmcloud_cluster_region` | IBM Cloud region for cluster resources. | REQUIRED with default defined | `ca-tor` (default) |
| `ibmcloud_resource_group` | IBM Cloud resource group name. Leave empty to use the account default. | REQUIRED with default defined | `default` (default) |

This deployment is modular and presents the following feature flag variables that control which components are orchestrated.

The deployment can orchestrate any or all of the following components:

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `create_cluster` | Create OpenShift ROKS cluster and its VPC infrastructure. | REQUIRED with default defined | `true` (default) |
| `create_cos_instance` | Create a Cloud Object Storage instance for the OpenShift internal image registry. Applies only when `create_cluster` is `true`. | REQUIRED with default defined | `true` (default) |
| `create_transit_gateway` | Create a Transit Gateway and connect the cluster VPC to it. | REQUIRED with default defined | `true` (default) |

### Deployment Variables — OpenShift ROKS Cluster

( Feature flags: `create_cluster`, `create_cos_instance` )

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `cluster_vpc_name` | Name of the cluster VPC to create or look up. | REQUIRED when `create_cluster` is `true` | `tf-cluster-vpc` (default) |
| `openshift_cluster_name` | Name of the OpenShift cluster to create. | REQUIRED when `create_cluster` is `true` | `tf-openshift-cluster` (default) |
| `openshift_cluster_version` | OpenShift version string. Leave empty to use the latest available version. | REQUIRED with default defined | `4.18` (default) |
| `workers_per_zone` | Number of worker nodes per availability zone (3 zones are always used). | REQUIRED when `create_cluster` is `true` | `1` (default) |
| `min_worker_vcpu_count` | Minimum vCPU count for worker node flavor auto-selection (bx2 series). | REQUIRED when `create_cluster` is `true` | `16` (default) |
| `min_worker_memory_gb` | Minimum memory in GB for worker node flavor auto-selection (bx2 series). | REQUIRED when `create_cluster` is `true` | `64` (default) |
| `cos_instance_name` | Name of the COS instance for the OpenShift registry. | Optional | `tf-openshift-cos-instance` (default) |

### Deployment Variables — Transit Gateway

( Feature flag: `create_transit_gateway` )

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `transit_gateway_name` | Name of the Transit Gateway to create. | REQUIRED when `create_transit_gateway` is `true` | `tf-tgw` (default) |

### Deployment Variables — Using an Existing Cluster VPC

If a cluster VPC already exists and should be used instead of creating a new one, set the following variables in the cluster module directly (via the `modules/cluster` variables).

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `use_existing_cluster_vpc` | Use an existing cluster VPC instead of creating one. | Optional | `false` (default) |
| `existing_cluster_vpc_id` | ID of the existing cluster VPC. Required when `use_existing_cluster_vpc` is `true`. | Conditional | `r006-...` |

## Project Directory Structure

```
ibmcloud_schematics_bigip_next_for_kubernetes_roks_cluster_4_18/
├── main.tf                    # Root module — wires variables into the cluster module
├── variables.tf               # Root module variable declarations
├── outputs.tf                 # Root module outputs
├── providers.tf               # IBM provider version constraint
├── terraform.tfvars.example   # Example variable values
└── modules/
    └── cluster/               # IBM Cloud OpenShift cluster infrastructure module
        ├── main.tf            # VPC, subnets, gateways, cluster, COS, Transit Gateway
        ├── variables.tf       # Cluster module variable declarations
        ├── outputs.tf         # Cluster module outputs
        └── providers.tf       # IBM provider version constraint for module
```

## Resources Provisioned

The `cluster` module creates the following IBM Cloud resources:

| Resource | Description |
| -------- | ----------- |
| `ibm_is_vpc.cluster_vpc` | VPC for the OpenShift cluster |
| `ibm_is_subnet.cluster_subnet_zone[1-3]` | One /24 subnet per availability zone |
| `ibm_is_public_gateway.cluster_gateway_zone[1-3]` | Public gateway per zone for outbound internet access |
| `ibm_is_subnet_public_gateway_attachment` | Attaches each public gateway to its subnet |
| `ibm_is_security_group_rule.cluster_sg_inbound_all` | Allows all inbound traffic on the cluster VPC default security group |
| `ibm_is_security_group_rule.cluster_tcp_80` | Allows inbound TCP/80 on the OpenShift-managed `kube-<cluster_id>` security group |
| `ibm_resource_instance.cos_instance` | Cloud Object Storage instance for the OpenShift internal image registry |
| `ibm_container_vpc_cluster.openshift_cluster` | IBM Cloud OpenShift ROKS 4.18 cluster |
| `ibm_tg_gateway.transit_gateway` | IBM Cloud Transit Gateway with global routing enabled |
| `ibm_tg_connection.cluster_vpc_connection` | Connects the cluster VPC to the Transit Gateway |

Worker node flavor is auto-selected as the smallest available `bx2` profile that meets `min_worker_vcpu_count` and `min_worker_memory_gb`. The OpenShift version is auto-selected as the latest available unless `openshift_cluster_version` is set.

## Local Installation & Deployment

### Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
2. IBM Cloud API key with sufficient IAM permissions to create VPC, OpenShift, COS, and Transit Gateway resources
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values

### Recommended Deployment Order

The workspace has a single module so a targeted apply is not required. However, the cluster takes 60–90 minutes to provision.

#### Step 1: Initialize

```bash
terraform init
```

#### Step 2: Plan

```bash
terraform plan
```

#### Step 3: Apply (60–90 min)

```bash
terraform apply -auto-approve
```

Or target just the cluster infrastructure:

```bash
terraform apply -target=module.cluster -auto-approve
```

### Cleanup

```bash
terraform destroy -auto-approve
```

### Example terraform.tfvars

```hcl
ibmcloud_api_key        = "YOUR_API_KEY"
ibmcloud_cluster_region = "ca-tor"
ibmcloud_resource_group = ""

# Feature flags
create_cluster         = true
create_transit_gateway = true
create_cos_instance    = true

# Cluster configuration
openshift_cluster_name    = "tf-openshift-cluster"
openshift_cluster_version = "4.18"
cluster_vpc_name          = "tf-cluster-vpc"
workers_per_zone          = 1
min_worker_vcpu_count     = 16
min_worker_memory_gb      = 64
cos_instance_name         = "tf-openshift-cos-instance"

# Transit Gateway configuration
transit_gateway_name = "tf-tgw"
```

## Outputs

View all outputs after apply:

```bash
terraform output                                        # All outputs
terraform output roks_cluster_id                        # OpenShift cluster ID
terraform output openshift_cluster_public_endpoint      # Public API endpoint
terraform output roks_transit_gateway_id                # Transit Gateway ID
terraform output kubeconfig_file_path                   # Path to kubeconfig
```

| Output | Description |
| ------ | ----------- |
| `roks_cluster_id` | ID of the OpenShift cluster |
| `roks_cluster_name` | Name of the OpenShift cluster |
| `openshift_cluster_id` | ID of the OpenShift cluster (alias) |
| `openshift_cluster_name` | Name of the OpenShift cluster (alias) |
| `openshift_cluster_public_endpoint` | Public API server endpoint URL |
| `openshift_cluster_private_endpoint` | Private API server endpoint URL |
| `openshift_cluster_ingress_hostname` | Ingress hostname |
| `openshift_cluster_state` | Cluster state |
| `openshift_cluster_crn` | CRN of the OpenShift cluster |
| `openshift_version_used` | Resolved OpenShift version (useful when auto-detected) |
| `available_openshift_versions` | All available OpenShift versions in the cluster region |
| `openshift_worker_zone1_ip` | Worker node IP address in zone 1 |
| `openshift_worker_zone2_ip` | Worker node IP address in zone 2 |
| `openshift_worker_zone3_ip` | Worker node IP address in zone 3 |
| `roks_cluster_vpc_id` | ID of the cluster VPC |
| `roks_cluster_vpc_name` | Name of the cluster VPC |
| `roks_cluster_vpc_crn` | CRN of the cluster VPC |
| `roks_transit_gateway_id` | ID of the Transit Gateway |
| `roks_transit_gateway_name` | Name of the Transit Gateway |
| `roks_transit_gateway_crn` | CRN of the Transit Gateway |
| `roks_transit_gateway_location` | Location of the Transit Gateway |
| `roks_transit_gateway_global_routing` | Whether global routing is enabled |
| `transit_gateway_connections` | Map of Transit Gateway connection names |
| `kubeconfig_file_path` | Path to the kubeconfig file (`~/.kube/config`) |

## Debugging & Troubleshooting

**Validate configuration:**

```bash
terraform validate
terraform state list
```

**List resources in the cluster module:**

```bash
terraform state list module.cluster
```

**Common issues:**

| Issue | Solution |
| ----- | -------- |
| Cluster creation times out after 120 min | Check IBM Cloud status for regional incidents. Re-run `terraform apply`; the cluster resource will resume. |
| `Error: no available zone` | The `min_worker_vcpu_count` / `min_worker_memory_gb` combination may not match any `bx2` flavor in the region. Lower the minimums or set `worker_flavor` explicitly. |
| COS instance quota exceeded | IBM Cloud allows one free COS instance per account. Set `create_cos_instance = false` and supply an existing COS instance, or remove the quota limit. |
| Transit Gateway connection pending | Transit Gateway connections can take several minutes to activate after the cluster VPC is attached. This is normal. |
