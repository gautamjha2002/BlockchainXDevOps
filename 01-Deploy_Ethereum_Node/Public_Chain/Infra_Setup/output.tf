# Output the public and private IP addresses of the Bastion Host
output "bastion_host_private_ip" {
  value = aws_instance.bastion_host.private_ip
}

output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

# Output the public and private IP addresses of Ethereum instances
output "ethereum_instances_private_ips" {
  value = aws_instance.ethereum[*].private_ip
}

