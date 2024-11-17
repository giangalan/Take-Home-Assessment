provider "aws" {
  region  = var.region # Change this to your desired AWS region
}

# specify ur own backend configuration
terraform {
  required_version = ">= 0.13"
  backend "s3" {
    bucket         = "cloudflare.healthcheck"
    key            = "us-east1/state.tfstate"
    region         = "us-east-1"
  }
}
