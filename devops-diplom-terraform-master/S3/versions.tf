terraform {
  required_providers {
    aws = {
      # source  = "terraform-registry.storage.yandexcloud.net/hashicorp/aws"
      source  = "hashicorp/aws"
      version = "~> 3.57"
    }
  }
  required_version = ">= 0.14.9"
  
  
}
