output "instance_ids" {
  value = aws_instance.app[*].id
}

output "eip_public_ips" {
  value = aws_eip.app_eip[*].public_ip
}

output "instance_public_dns" {
  value = aws_instance.app[*].public_dns
}
