variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "The Cidr range for VPC"
}

variable "public_subnet_cidr" {
  type = string 
  default = "10.0.1.0/24"
}

variable "availability_zone_1" {
  type = string
  default = "us-east-1a"
}


