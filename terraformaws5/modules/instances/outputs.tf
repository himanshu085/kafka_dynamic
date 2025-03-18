output "public_instance_ip" {
  value = aws_instance.public_instance.public_ip
}

output "private_instance_ip" {
  value = aws_instance.private_instance.private_ip
}

output "nlb_dns_name" {
  value = aws_lb.kafka_nlb.dns_name
}

