# VPC Configuration
cidr_block = "10.0.0.0/16"
vpc_name   = "Kafka-VPC"

# Subnet Configuration
public_subnet_1_cidr  = "10.0.1.0/24"
public_subnet_2_cidr  = "10.0.2.0/24"
private_subnet_1_cidr = "10.0.3.0/24"
private_subnet_2_cidr = "10.0.4.0/24"

# Availability Zones
az_1 = "us-east-1a"
az_2 = "us-east-1b"

# Security Groups Configuration
vpc_cidr = "10.0.0.0/16"

# EC2 Instance Configuration
ami           = "ami-0e1bed4f06a3b463d"
instance_type = "m5.large"

# SSH Key Pair
key_name = "vmkey"

# Placeholder values for dynamic resources (These get filled after Terraform apply)
vpc_id                    = ""
public_subnet_id          = ""
private_subnet_id         = ""
public_security_group_id  = ""
private_security_group_id = ""
bastion_host              = ""

