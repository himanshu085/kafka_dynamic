variable "ami" {
  type    = string
  default = "ami-0e1bed4f06a3b463d"
}

variable "instance_type" {
  type    = string
  default = "t2.large"
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type    = string
  default = "vmkey"
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "public_security_group_id" {
  type = string
}

variable "private_security_group_id" {
  type = string
}

variable "private_key_path" {
  type    = string
  default = "/var/lib/jenkins/workspace/vmkey.pem"
}

variable "bastion_host" {
  type = string
}

