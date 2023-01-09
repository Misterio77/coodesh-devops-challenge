terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.9.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }
  }
}

provider "aws" {
  # Hardcodada como us-east-1, pois o cloudfront & ACM só suportam ele
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html#https-requirements-aws-region
  # Caso seja nescessário ter recursos em outra região, é possível fazer mais que um provider.
  region = "us-east-1"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
