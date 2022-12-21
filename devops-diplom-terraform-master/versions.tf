terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.57"
    }
  }
  required_version = ">= 0.14.9"
  
  # The backend is not working due to region blocking.
  # backend "remote" {
  #   hostname = "app.terraform.io"
  #   organization = "Alienorg"

  #   workspaces {
  #     name = "stage"
  #   }
  backend "s3" {
    bucket = "netology-diplom-bucket-nkardash"
    encrypt = true
    key = "netology/test-infra/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
    }
  # }
}
