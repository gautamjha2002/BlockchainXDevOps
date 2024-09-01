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



resource "aws_security_group" "alb_sg" {
  vpc_id = module.create_vpc.vpc_id

  ingress {
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust as needed
  }

  ingress {
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust as needed
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
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

  ingress {
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic from the ALB
  }

  ingress {
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic from the ALB
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



