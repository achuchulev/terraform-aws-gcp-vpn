provider "google" {
  version = ">= 2.11.0"

  credentials = file(var.gcp_credentials_file_path)

  # Should be able to parse project from credentials file but cannot.
  # Cannot convert string to map and cannot interpolate within variables.
  project = var.gcp_project_id

  region = var.gcp_region
}

provider "aws" {
  version = ">= 2.21.1"

  access_key = var.access_key
  secret_key = var.secret_key
  region = var.aws_region
}

