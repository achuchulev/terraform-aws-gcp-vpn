# Sample terraform configuration to setup a VPN Between VPCs in GCP and AWS

## Prerequisites

- git
- terraform (>= 0.12)
- GCP subscription
- AWS subscription

## How to use

- Create `terraform.tfvars` file

```
gcp_credentials_file_path = "/path/to/your/gcloud/credentials.json"
aws_credentials_file_path = "/path/to/your/aws/credentials"
aws-vpc-id = "your_vpc_id"
gcp_project_id = "your_project_id"
gcp-network-name = "gcp_vpc_network_name"
gcp-subnet1-name = "gcp_vpc_subnet1_name"
```

- Create `variables.tf` file

```
variable "gcp_credentials_file_path" {}
variable "gcp_region" {}
variable "gcp_project_id" {}
variable "gcp-network-name" {}
variable "gcp-subnet1-name" {}
variable "aws_credentials_file_path" {}
variable "aws_region" {}
variable "aws-vpc-id" {}

```

#### Inputs

| Name  |	Description |	Type |  Default |	Required
| ----- | ----------- | ---- |  ------- | --------
| gcp_credentials_file_path | Locate the GCP credentials .json file. | string  | - | yes
| gcp_project_id | GCP Project ID. | string  | - | yes
| gcp_region | GCP region | string  | yes | yes
| gcp-network-name | VPC network name | string  | - | yes
| gcp_subnet1_cidr | VPC subnet CIDR block | string  | yes | yes
| aws_credentials_file_path | Locate the AWS credentials file | string  | - | yes
| aws_region | AWS region | string  | yes | yes
| aws-vpc-id | AWS VPC id | string  | - | yes
| GCP_TUN1_VPN_GW_ASN | Tunnel 1 - Virtual Private Gateway ASN | number  | yes | no
| GCP_TUN1_CUSTOMER_GW_INSIDE_NETWORK_CIDR | Tunnel 1 - Customer Gateway from Inside IP Address CIDR block | number  | yes | no
| GCP_TUN2_VPN_GW_ASN | Tunnel 2 - Virtual Private Gateway ASN | number  | yes | no
| GCP_TUN2_CUSTOMER_GW_INSIDE_NETWORK_CIDR | Tunnel 2 - Customer Gateway from Inside IP Address CIDR block | number  | yes | no

- Create `main.tf` file

```
module "aws-gcp-vpn" {
  source = "git@github.com:achuchulev/terraform-aws-gcp-vpn.git"
  
  gcp_credentials_file_path = var.gcp_credentials_file_path
  gcp_project_id            = var.gcp_project_id
  gcp-network-name          = var.gcp-network-name
  gcp-subnet1-name          = var.gcp-subnet1-name
  gcp_region                = var.gcp_region
  aws_credentials_file_path = var.aws_credentials_file_path
  aws_region                = var.aws_region
  aws-vpc-id                = var.aws-vpc-id
}

```

- Initialize terraform and plan/apply

```
$ terraform init
$ terraform plan
$ terraform apply
```

- `Terraform apply` will create:
  - on AWS
    - VPN Gateway 
    - Customer Gateway
    - default Internet route
    - security groups to allow ICMP, SSH, VPN ans Internet traffic
    
  - on GCP 
    - public IP address
    - VPN GW
    - forwarding rules for IP protocols ESP, UDP 500 & 4500 and
    - two VPN tunnels
    - 2 routers
    - 2 router interfaces
    - 2 router peers
    - FW rules to allow traffic from the VPN subnets
   
