resource "aws_launch_template" "etcd" {
  name                   = "${var.solution_short}-${var.env}-etcd"
  description            = "${var.solution_short}-${var.env} Etcd Launch Template"
  update_default_version = true
  image_id               = var.asg_etcd_ImageName
  instance_type          = var.asg_etcd_instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_etcd_id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.etcd.name
  }

  monitoring {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tftpl", {
    CONFIG_S3_BUCKET = aws_s3_bucket.config_bucket.id
    }
    )
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.solution_short}-${var.env}-etcd"
      Solution    = var.solution
      Environment = var.env
      shutOff     = var.asg_etcd_shutoff
      Backup      = var.asg_etcd_backup
      component   = "etcd"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "${var.solution_short}-${var.env}-etcd"
      component   = "etcd"
      Solution    = var.solution
      Environment = var.env
    }
  }

  tags = {
    Name = "${var.solution_short}-${var.env}-etcd"
  }
}

resource "aws_autoscaling_group" "etcd" {
  name                      = "${var.solution_short}-${var.env}-etcd"
  desired_capacity          = var.asg_etcd_DesiredSize
  max_size                  = var.asg_etcd_MaxSize
  min_size                  = var.asg_etcd_MinSize
  default_cooldown          = 10
  health_check_type         = "EC2"
  health_check_grace_period = 10

  launch_template {
    id      = aws_launch_template.etcd.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnets_public_ids

  tag {
    key                 = "Name"
    value               = "${var.solution_short}-${var.env}-etcd"
    propagate_at_launch = true
  }
  tag {
    key                 = "shutOff"
    value               = var.asg_etcd_shutoff
    propagate_at_launch = true
  }
  tag {
    key                 = "backup"
    value               = var.asg_etcd_backup
    propagate_at_launch = true
  }
  tag {
    key                 = "component"
    value               = "etcd"
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
