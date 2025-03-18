terraform {
  backend "s3" {
    bucket         = "parashar086"               # Your S3 bucket name
    key            = "terraform/state.tfstate"   # Path to the state file in the bucket
    region         = "us-east-1"                 # AWS region
    encrypt        = true                        # Enable encryption for state files
    dynamodb_table = "terraform-lock"            # DynamoDB table for state locking
    acl            = "bucket-owner-full-control" # Set S3 ACL to prevent unauthorized access
  }
}

provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source                = "./modules/networking"
  cidr_block            = var.cidr_block
  vpc_name              = var.vpc_name
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  az_1                  = var.az_1
  az_2                  = var.az_2
}

module "security_groups" {
  source               = "./modules/security_groups"
  vpc_id               = module.networking.vpc_id
  vpc_cidr             = var.vpc_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
}

module "instances" {
  source                    = "./modules/instances"
  ami                       = var.ami
  instance_type             = var.instance_type
  vpc_id                    = module.networking.vpc_id
  public_subnet_id          = module.networking.public_subnet_1_id
  private_subnet_id         = module.networking.private_subnet_1_id
  public_security_group_id  = module.security_groups.public_security_group_id
  private_security_group_id = module.security_groups.private_security_group_id
  key_name                  = var.key_name
  bastion_host              = module.instances.public_instance_ip
}
