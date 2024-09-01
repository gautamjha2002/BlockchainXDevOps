
resource "aws_lb" "eth_lb" {
  name = "eth-loadbalancer"
  internal = false 
  load_balancer_type = "application"
  subnets = module.create_vpc.subnet_ids
  security_groups = [aws_security_group.alb_sg.id]
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "Ethereum Loadbalancer"
  }
}

resource "aws_lb_target_group" "rpc_tg" {
  name     = "rpc-target-group"
  port     = 8085
  protocol = "HTTP"
  vpc_id   = module.create_vpc.vpc_id

  health_check {
    path                = "/"  # Adjust as necessary
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "RPC Target Group"
  }
}

resource "aws_lb_target_group" "websocket_tg" {
  name     = "websocket-target-group"
  port     = 8086
  protocol = "HTTP"
  vpc_id   = module.create_vpc.vpc_id

  health_check {
    path                = "/"  # Adjust as necessary
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "WebSocket Target Group"
  }
}

resource "aws_lb_listener" "rpc_listener" {
  load_balancer_arn = aws_lb.eth_lb.arn
  port              = 8085
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rpc_tg.arn
  }
}

resource "aws_lb_listener" "websocket_listener" {
  load_balancer_arn = aws_lb.eth_lb.arn
  port              = 8086
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.websocket_tg.arn
  }
}
