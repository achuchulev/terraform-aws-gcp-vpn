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
gcp_project_id            = "your_project_id"
gcp_network_name          = "gcp_vpc_network_name"
gcp_subnet_name           = "gcp_vpc_subnet1_name"
access_key                = "your_aws_access_key"
secret_key                = "your_aws_secret_key"
aws_vpc_id                = "your_vpc_id"
aws_subnet_cidrs          = ["10.100.0.0/24","10.100.1.0/24"]
```

- Create `variables.tf` file

```
variable "gcp_credentials_file_path" {}
variable "gcp_region" {}
variable "gcp_project_id" {}
variable "gcp_network_name" {}
variable "gcp_subnet_name" {}
variable "access_key" {}
variable "secret_key" {}
variable "aws_region" {}
variable "aws_vpc_id" {}
variable "aws_subnet_cidrs" {}

```

#### Inputs

| Name  |	Description |	Type |  Default |	Required
| ----- | ----------- | ---- |  ------- | --------
| gcp_credentials_file_path | Locate the GCP credentials .json file. | string  | - | yes
| gcp_project_id | GCP Project ID. | string  | - | yes
| gcp_region | GCP region | string  | yes | yes
| gcp_network_name | VPC network name | string  | - | yes
| gcp_subnet_name | VPC subnet name | string  | - | yes
| access_key | Requester AWS access key | string | - | yes
| secret_key | Requester AWS secret key | string | - | yes
| aws_region | AWS region | string  | yes | yes
| aws_vpc_id | AWS VPC id | string  | - | yes
| aws_subnet_cidrs | List of AWS VPC subnet cidrs | list | - | yes
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
  gcp_network_name          = var.gcp_network_name
  gcp_subnet_name           = var.gcp_subnet1_name
  gcp_region                = var.gcp_region
  access_key                = var.access_key
  secret_key                = var.secret_key
  aws_region                = var.aws_region
  aws_vpc_id                = var.aws_vpc_id
  aws_subnet_cidrs          = var.aws_subnet_cidrs
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
   
