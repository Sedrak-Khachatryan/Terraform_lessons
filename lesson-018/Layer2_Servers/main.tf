provider "aws" {
  region = "ca-central-1"
}

terraform {
  backend "s3" {
    bucket = "silvertigo-first-project"
    key    = "dev/servers/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "silvertigo-first-project"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}


resource "aws_security_group" "webserver" {
  name   = "WebServer Security Group"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "web-server-sg"
    Owner = "Sedrak Khachatryan"
  }
}

output "webserver_sg_id" {
  value = aws_security_group.webserver.id
}
