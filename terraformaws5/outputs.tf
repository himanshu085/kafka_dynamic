#networkings outputs

output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_1_id" {
  value = module.networking.public_subnet_1_id
}

output "public_subnet_2_id" {
  value = module.networking.public_subnet_2_id
}

output "private_subnet_1_id" {
  value = module.networking.private_subnet_1_id
}

output "private_subnet_2_id" {
  value = module.networking.private_subnet_2_id
}

output "nat_gateway_id" {
  value = module.networking.nat_gateway_id
}

#Security group modules outputs

output "public_security_group_id" {
  value = module.security_groups.public_security_group_id
}

output "private_security_group_id" {
  value = module.security_groups.private_security_group_id
}

#Instances outputs

output "public_instance_ip" {
  value = module.instances.public_instance_ip
}

output "private_instance_ip" {
  value = module.instances.private_instance_ip
}

output "nlb_dns_name" {
  value = module.instances.nlb_dns_name
}

