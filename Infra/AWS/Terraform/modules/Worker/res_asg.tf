resource "aws_launch_template" "worker" {
  name                   = "${var.solution_short}-${var.env}-worker"
  description            = "${var.solution_short}-${var.env} worker Launch Template"
  update_default_version = true
  image_id               = var.asg_worker_ImageName
  instance_type          = var.asg_worker_instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_worker_id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.worker.name
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
    CONFIG_S3_BUCKET = var.config_bucket_id
    }
    )
  )

  # tag_specifications {
  #   resource_type = "instance"

  #   tags = {
  #     Name                               = "${var.solution_short}-${var.env}-worker"
  #     Solution                           = var.solution
  #     Environment                        = var.env
  #     shutOff                            = var.asg_worker_shutoff
  #     Backup                             = var.asg_worker_backup
  #     component                          = "worker"
  #     "kubernetes.io/cluster/kubernetes" = "owned"
  #   }
  # }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name                               = "${var.solution_short}-${var.env}-worker"
      component                          = "worker"
      Solution                           = var.solution
      Environment                        = var.env
      "kubernetes.io/cluster/kubernetes" = "owned"
    }
  }

  tags = {
    Name = "${var.solution_short}-${var.env}-worker"
  }
}

resource "aws_autoscaling_group" "worker" {
  name                      = "${var.solution_short}-${var.env}-worker"
  desired_capacity          = var.asg_worker_DesiredSize
  max_size                  = var.asg_worker_MaxSize
  min_size                  = var.asg_worker_MinSize
  default_cooldown          = 10
  health_check_type         = "EC2"
  health_check_grace_period = 10
  suspended_processes       = []

  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnets_public_ids

  tag {
    key                 = "Name"
    value               = "${var.solution_short}-${var.env}-worker"
    propagate_at_launch = true
  }
  tag {
    key                 = "shutOff"
    value               = var.asg_worker_shutoff
    propagate_at_launch = true
  }
  tag {
    key                 = "backup"
    value               = var.asg_worker_backup
    propagate_at_launch = true
  }
  tag {
    key                 = "component"
    value               = "worker"
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
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/foo"
    value               = "bar"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.env}"
    value               = var.env
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }
}
