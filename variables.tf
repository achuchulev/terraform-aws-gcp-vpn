// ------------- AWS VARS -------------
variable "access_key" {}

variable "secret_key" {}

variable "aws_region" {
  description = "Default to N.Virginia region."
  default     = "us-east-1"
}

variable "aws-vpc-id" {
  description = "AWS VPC id"
}

variable "aws_subnet_cidrs" {
  description = "List of AWS VPC subnet cidrs"
  type        = list
}


// ------------- GCP VARS -------------

variable "gcp_credentials_file_path" {
  description = "Locate the GCP credentials .json file."
  type        = string
}

variable "gcp_project_id" {
  description = "GCP Project ID."
  type        = string
}

variable "gcp_region" {
  description = "Default to Oregon region."
  default     = "us-east4"
}

variable "gcp-network-name" {
  description = "GCP VPC Name"
}

variable "gcp-subnet1-name" {
  description = "GCP VPC Subnet Name"
}

variable "GCP_TUN1_VPN_GW_ASN" {
  description = "Tunnel 1 - Virtual Private Gateway ASN, from the AWS VPN Customer Gateway Configuration"
  default     = "64512"
}

variable "GCP_TUN1_CUSTOMER_GW_INSIDE_NETWORK_CIDR" {
  description = "Tunnel 1 - Customer Gateway from Inside IP Address CIDR block, from AWS VPN Customer Gateway Configuration"
  default     = "30"
}

variable "GCP_TUN2_VPN_GW_ASN" {
  description = "Tunnel 2 - Virtual Private Gateway ASN, from the AWS VPN Customer Gateway Configuration"
  default     = "64512"
}

variable "GCP_TUN2_CUSTOMER_GW_INSIDE_NETWORK_CIDR" {
  description = "Tunnel 2 - Customer Gateway from Inside IP Address CIDR block, from AWS VPN Customer Gateway Configuration"
  default     = "30"
}

