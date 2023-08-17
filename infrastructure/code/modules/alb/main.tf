# create security group for alb
resource "aws_security_group" "load_balancer" {
  vpc_id = var.vpc_id
  name   = "${var.project_name}-${var.app_name}-alb-sg"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.app_name}-alb-sg"
  }
}

# Create alb
resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [for subnet in var.public_subnets : subnet.id]

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "okay"
      status_code  = "200"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-sample-app-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    port                = "3000"
    interval            = "10"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
  }

  depends_on = [
    aws_lb.alb
  ]

  tags = {
    Name = "${var.project_name}-sample-app-lb-tg"
  }
}

resource "aws_lb_listener_rule" "this" {
  action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
  listener_arn = aws_alb_listener.https.arn
  priority     = "100"
}