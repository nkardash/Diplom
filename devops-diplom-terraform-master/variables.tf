variable "aws-region" {
  default = "us-east-1"
  description = "Default Amazon region"
}
variable "aws-av-zone" {
  default = "us-east-1a"
  description = "Avaliability zone"
}

locals {
web_instance_type_map = {
  stage = "t2.micro"
  prod = "t3.small"
  }
web_instance_count_map = {
  stage = 1
  prod = 3
  }
instances = {
  "t2.micro" = data.aws_ami.ubuntu.id
  "t3.small" = data.aws_ami.ubuntu.id
  }
}
