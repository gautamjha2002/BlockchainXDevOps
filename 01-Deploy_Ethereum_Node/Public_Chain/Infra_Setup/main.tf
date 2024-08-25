module "create_vpc" {
  source = "./vpc"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion_host" {
  ami = data.aws_ami.ubuntu.id 
  instance_type = "t2.micro"

  tags = {
    Name = "Bastion Host"
  }

  associate_public_ip_address = true 
  subnet_id = module.create_vpc.vpc_id 
  security_groups = [ "aws_security_group.bastion_sg", "aws_security_group.private_sg" ]
}

resource "aws_instance" "ethereum" {
  ami = data.aws_ami.ubuntu.id 
  instance_type = "t2.micro"
  count = 2
   security_groups = [ "aws_security_group.private_sg" ]

  tags = {
    Name = "Ethereum-${count.index}"
  }

  subnet_id = module.create_vpc.public_blockchain_subnet_private_ids[count.index]
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = module.create_vpc.vpc_id

  tags = {
    Name = "Bastion Host Security Group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "private_sg" {
  vpc_id = module.create_vpc.vpc_id

  tags = {
    Name = "Private Instances Security Group"
  }

  # Allow all traffic from the public subnet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = [module.create_vpc.public_subnet_cidr]
  }

  # Allow all traffic from the private subnets
  dynamic "ingress" {
    for_each = module.create_vpc.private_subnet_cidrs
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"  # Allow all protocols
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}


