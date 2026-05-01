variable "aws_region" {
  description = "AWS region where demo VMs are created."
  type        = string
}

variable "project_name" {
  description = "Project tag value applied to all resources."
  type        = string
}

variable "environment" {
  description = "Environment tag value applied to all resources."
  type        = string
}

variable "owner" {
  description = "Owner tag value applied to all resources."
  type        = string
}

variable "reason" {
  description = "Reason tag value applied to all resources."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the VM image (Ubuntu recommended for this demo)."
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name used for SSH."
  type        = string
}

variable "ssh_private_key_path" {
  description = "Local path to the private key used for SSH command output."
  type        = string
}

variable "ssh_user" {
  description = "SSH username for the AMI (for example, ec2-user or ubuntu)."
  type        = string
  default     = "ec2-user"
}

variable "vpc_cidr" {
  description = "CIDR block for the demo VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the demo public subnet."
  type        = string
  default     = "10.42.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the public subnet (for example, us-east-1a)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for demo VMs."
  type        = string
  default     = "t3.micro"
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH to VMs. Restrict this in real environments."
  type        = string
  default     = "0.0.0.0/0"
}
