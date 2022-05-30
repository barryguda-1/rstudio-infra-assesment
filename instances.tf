terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

#Get Linux AMI ID using SSM Parameter endpoint
data "aws_ssm_parameter" "rstudio-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for logging into EC2 instance
resource "aws_key_pair" "instance-key" {
  key_name   = "admin"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Create and bootstrap EC2 instance
resource "aws_instance" "rstudio-master" {
  ami                         = data.aws_ssm_parameter.rstudio-ami.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.instance-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.rstudio-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id
  tags = {
    Name = "rstudio-instance1"
  }

  provisioner "file" {
    source      = "rstudio-install-script/r-connect.sh"
    destination = "/tmp/r-connect.sh"
  }

  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/r-connect.sh",
      "sed -i -e 's/\r$//' /tmp/r-connect.sh",
      "bash /tmp/r-connect.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

}


