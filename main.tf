terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.0"
}
provider "aws" {
  access_key = $(AK)
  secret_key = "$(SK)
  token = $(TO)
  region     = "eu-central-1"
  default_tags {
    tags = {
      Owner = "danila_bochkarev@epam.com"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"] # amazon
}

data "aws_vpcs" "print" {}
data "aws_subnets" "print" {}
data "aws_security_groups" "print" {}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [data.aws_security_groups.print.ids[5]]
  subnet_id = data.aws_subnets.print.ids[0]
  key_name = "danila_bochkarev@epam.com"
  user_data = <<EOF
  #cloud-config
  package_update: true
  package_upgrade: true
  runcmd:
  - yum update -y
  - amazon-linux-extras install -y nginx1
  - service nginx start
EOF

 volume_tags = {
    Owner = "danila_bochkarev@epam.com"
  }
  tags = {
    "Name" = "tf_nginx"
  }
}


resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "5.7"
  identifier           = "mysql-tf-test"
  instance_class       = "db.t2.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [data.aws_security_groups.print.ids[5]]
  skip_final_snapshot  = true
}


output "data_aws_vpcs" {
  value = data.aws_vpcs.print.ids
}
output "data_aws_subnets" {
  value = data.aws_subnets.print.ids
}
output "data_aws_security_groups" {
  value = data.aws_security_groups.print.ids
}
