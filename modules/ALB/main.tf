# ─── SECURITY GROUP — ALB ───────────────────────────────────

resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.environment}-alb-sg"
    ManagedBy = "terraform"
  }
}

# ─── APPLICATION LOAD BALANCER ──────────────────────────────

resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name      = "${var.environment}-alb"
    ManagedBy = "terraform"
  }
}

# ─── TARGET GROUP ───────────────────────────────────────────

resource "aws_lb_target_group" "app" {
  name     = "${var.environment}-app-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name      = "${var.environment}-app-tg"
    ManagedBy = "terraform"
  }
}

# ─── TARGET GROUP ATTACHMENT ─────────────────────────────────

resource "aws_lb_target_group_attachment" "app" {
  count = length(var.app_instance_ids)
  # runs once per app server
  # 2 servers → 2 attachments
  # 3 servers → 3 attachments
  # automatically scales with however many servers you have

  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.app_instance_ids[count.index]
  # count.index=0 → registers app-server-1
  # count.index=1 → registers app-server-2
  # count.index=2 → registers app-server-3
  port             = var.app_port
}

# ─── LISTENER ───────────────────────────────────────────────

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
