terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  calculated_end_date = formatdate("YYYY-MM-DD", timeadd(timestamp(), "720h"))

  common_tags = {
    Project             = var.project_name
    Environment         = var.environment
    ManagedBy           = "terraform"
    Owner               = var.owner
    Reason              = var.reason
    "expected-end-date" = local.calculated_end_date
    CreatedDate         = formatdate("YYYY-MM-DD", timestamp())
  }
}

resource "aws_vpc" "ansible_demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "ansible-demo-vpc" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ansible_demo.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "ansible-demo-public-subnet" })
}

resource "aws_internet_gateway" "ansible_demo" {
  vpc_id = aws_vpc.ansible_demo.id

  tags = merge(local.common_tags, { Name = "ansible-demo-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ansible_demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ansible_demo.id
  }

  tags = merge(local.common_tags, { Name = "ansible-demo-public-rt" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ansible_demo" {
  name        = "ansible-demo-sg"
  description = "Allows SSH access for Ansible runs"
  vpc_id      = aws_vpc.ansible_demo.id

  ingress {
    description = "SSH from approved CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "ansible-demo-sg" })
}

resource "aws_instance" "vm" {
  count = 2

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ansible_demo.id]

  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name = "ansible-demo-vm-${count.index + 1}"
      Role = "java-target"
    }
  )
}
