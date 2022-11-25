/* resource "aws_lb" "control_plane" {
  name               = "${var.solution_short}-${var.env}-control-plane"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnets_public_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.solution_short}-${var.env}-control_plane"
  }
}

resource "aws_lb_listener" "control_plane" {
  load_balancer_arn = aws_lb.control_plane.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.control_plane.arn
  }

  tags = {
    Name = "${var.solution_short}-${var.env}-control_plane"
  }
} */

resource "aws_launch_template" "lb" {
  name                   = "${var.solution_short}-${var.env}-lb"
  description            = "${var.solution_short}-${var.env} lb Launch Template"
  update_default_version = true
  image_id               = var.asg_lb_ImageName
  instance_type          = var.asg_lb_instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_lb_id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.lb.name
  }

  monitoring {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(templatefile("${path.module}/templates/lb_user_data.sh.tftpl", {
    CONFIG_S3_BUCKET = var.config_bucket_id
    }
    )
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.solution_short}-${var.env}-lb"
      Solution    = var.solution
      Environment = var.env
      shutOff     = var.asg_lb_shutoff
      Backup      = var.asg_lb_backup
      component   = "lb"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "${var.solution_short}-${var.env}-lb"
      component   = "lb"
      Solution    = var.solution
      Environment = var.env
    }
  }

  tags = {
    Name = "${var.solution_short}-${var.env}-lb"
  }
}

resource "aws_autoscaling_group" "lb" {
  name                      = "${var.solution_short}-${var.env}-lb"
  desired_capacity          = var.asg_lb_DesiredSize
  max_size                  = var.asg_lb_MaxSize
  min_size                  = var.asg_lb_MinSize
  default_cooldown          = 10
  health_check_type         = "EC2"
  health_check_grace_period = 10
  suspended_processes       = []

  launch_template {
    id      = aws_launch_template.lb.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnets_public_ids

  tag {
    key                 = "Name"
    value               = "${var.solution_short}-${var.env}-lb"
    propagate_at_launch = true
  }
  tag {
    key                 = "shutOff"
    value               = var.asg_lb_shutoff
    propagate_at_launch = true
  }
  tag {
    key                 = "backup"
    value               = var.asg_lb_backup
    propagate_at_launch = true
  }
  tag {
    key                 = "component"
    value               = "lb"
    propagate_at_launch = true
  }
  tag {
    key                 = "Solution"
    value               = var.solution
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }
}
