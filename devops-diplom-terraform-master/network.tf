module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "diplom_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = terraform.workspace
  }
}
