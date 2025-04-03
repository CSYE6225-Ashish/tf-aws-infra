resource "aws_lb" "webapp_loadbalancer" {
  name               = "webapp-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webapp_loadbalancer_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
}

resource "aws_lb_target_group" "webapp_loadbalancer_tg" {
  name     = "webapp-loadbalancer-tg"
  port     = var.PORT
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    path                = "/healthz"
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.webapp_loadbalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_loadbalancer_tg.arn
  }
}