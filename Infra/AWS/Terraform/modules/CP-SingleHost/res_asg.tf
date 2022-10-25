resource "aws_launch_template" "control_plane" {
  name                   = "${var.solution_short}-${var.env}-control_plane"
  description            = "${var.solution_short}-${var.env} control_plane Launch Template"
  update_default_version = true
  image_id               = var.asg_control_plane_ImageName
  instance_type          = var.asg_control_plane_instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_control_plane_id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.control_plane.name
  }

  monitoring {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 3
  }

  user_data = base64encode(templatefile("${path.module}/templates/control_plane_user_data.sh.tftpl", {
    CONFIG_S3_BUCKET = aws_s3_bucket.config_bucket.id
    ENV              = var.env
    }
    )
  )

  # tag_specifications {
  #   resource_type = "instance"

  #   tags = {
  #     Name                               = "${var.solution_short}-${var.env}-control_plane"
  #     Solution                           = var.solution
  #     Environment                        = var.env
  #     shutOff                            = var.asg_control_plane_shutoff
  #     Backup                             = var.asg_control_plane_backup
  #     component                          = "control_plane"
  #     "kubernetes.io/cluster/kubernetes" = "owned"
  #   }
  # }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name                               = "${var.solution_short}-${var.env}-control_plane"
      component                          = "control_plane"
      Solution                           = var.solution
      Environment                        = var.env
      "kubernetes.io/cluster/kubernetes" = "owned"
    }
  }

  tags = {
    Name = "${var.solution_short}-${var.env}-control_plane"
  }
}

resource "aws_autoscaling_group" "control_plane" {
  name                      = "${var.solution_short}-${var.env}-control_plane"
  desired_capacity          = var.asg_control_plane_DesiredSize
  max_size                  = var.asg_control_plane_MaxSize
  min_size                  = var.asg_control_plane_MinSize
  default_cooldown          = 10
  health_check_type         = "EC2"
  health_check_grace_period = 10
  suspended_processes       = []

  launch_template {
    id      = aws_launch_template.control_plane.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnets_public_ids

  tag {
    key                 = "Name"
    value               = "${var.solution_short}-${var.env}-control_plane"
    propagate_at_launch = true
  }
  tag {
    key                 = "shutOff"
    value               = var.asg_control_plane_shutoff
    propagate_at_launch = true
  }
  tag {
    key                 = "backup"
    value               = var.asg_control_plane_backup
    propagate_at_launch = true
  }
  tag {
    key                 = "component"
    value               = "control_plane"
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
  tag {
    key                 = "kubernetes.io/cluster/${var.env}"
    value               = "owned"
    propagate_at_launch = true
  }
}
