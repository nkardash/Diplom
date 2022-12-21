# Configure the AWS Provider
provider "aws" {
  region                  = var.aws-region
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
}


resource "aws_s3_bucket" "nkardash-bucket" {
  bucket = "netology-diplom-bucket-nkardash"
  
  tags = {
    Name        = "My bucket"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_acl" "netology-diplom-bucket-nkardash" {
  bucket = aws_s3_bucket.nkardash-bucket.id
  acl    = "private"
}

resource "aws_dynamodb_table" "dynamodb-terraform-lock" {
   name = "terraform-lock"
   hash_key = "LockID"
   read_capacity = 20
   write_capacity = 20

   attribute {
      name = "LockID"
      type = "S"
   }

   tags = {
     Name = "Terraform Lock Table"
   }
}
