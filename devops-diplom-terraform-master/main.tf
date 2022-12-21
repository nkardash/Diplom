# Configure the AWS Provider
provider "aws" {
  region                  = var.aws-region
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
}
# We find AMI for Ubuntu 20.04
  data "aws_ami" "ubuntu" {
    most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}
data "aws_caller_identity" "current" {}

resource "aws_instance" "diplom_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  key_name  = aws_key_pair.laptop.key_name
  count = local.web_instance_count_map[terraform.workspace]
  subnet_id     = module.vpc.public_subnets[0]
  availability_zone = var.aws-av-zone
  associate_public_ip_address = "true"
  instance_initiated_shutdown_behavior = "stop"
  vpc_security_group_ids = [aws_security_group.diplom_sec_group.id]

  tags = {
    Name = "Diplom servers"
  }
  
}

