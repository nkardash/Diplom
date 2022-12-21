resource "aws_security_group" "diplom_sec_group"{
  vpc_id = module.vpc.vpc_id
  name        = "allow_http_and_ssh"
  description = "Allow HTTP and SSH inbound traffic"

  egress {
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["10.0.101.0/24"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30000
    protocol = "tcp"
    to_port = 30000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30001
    protocol = "tcp"
    to_port = 30001
    cidr_blocks = ["0.0.0.0/0"]
  }  
}