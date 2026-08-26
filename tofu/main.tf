terraform {
  required_providers {
    aws = {
      source = "opentofu/aws"
      version = "6.61.0"
    }
    namecheap = {
      source = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

provider "namecheap" {
  user_name = "Weastie"
  api_user = "Weastie"
  client_ip = "141.158.45.214"
}
