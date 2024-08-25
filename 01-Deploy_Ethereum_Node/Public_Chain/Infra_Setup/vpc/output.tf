output "vpc_id" {
  value = aws_vpc.public_blockchain_vpc.id
}


output "public_blockchain_subnet_private_ids" {
  value = aws_subnet.public_blockchain_subnet_private[*].id
}


# Output the CIDR blocks of the subnets in your vpc module
output "public_subnet_cidr" {
  value = aws_subnet.public_blockchain_subnet_public.cidr_block
}

output "private_subnet_cidrs" {
  value = aws_subnet.public_blockchain_subnet_private[*].cidr_block
}
