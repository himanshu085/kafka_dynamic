variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
}

variable "az_1" {
  description = "Availability Zone for first subnet"
  type        = string
}

variable "az_2" {
  description = "Availability Zone for second subnet"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate security groups and instances"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for EC2"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for EC2"
  type        = string
}

variable "public_security_group_id" {
  description = "Security Group ID for public instances"
  type        = string
}

variable "private_security_group_id" {
  description = "Security Group ID for private instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
}

variable "bastion_host" {
  description = "Public IP of the bastion host"
  type        = string
}
