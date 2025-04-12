resource "aws_autoscaling_group" "webapp_application_autoscaling_group" {
  name                      = "webapp-app-asg"
  min_size                  = var.webapp_application_autoscaling_group_min_size
  max_size                  = var.webapp_application_autoscaling_group_max_size
  desired_capacity          = var.webapp_application_autoscaling_group_desired_capacity
  vpc_zone_identifier       = [for subnet in aws_subnet.public : subnet.id]
  health_check_type         = "EC2"
  health_check_grace_period = var.webapp_application_autoscaling_group_health_check_grace_period

  launch_template {
    id      = aws_launch_template.app_server_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.webapp_loadbalancer_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.custom_ami}-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_up_cooldown
  autoscaling_group_name = aws_autoscaling_group.webapp_application_autoscaling_group.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_down_cooldown
  autoscaling_group_name = aws_autoscaling_group.webapp_application_autoscaling_group.name
}


resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_high_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_high_period
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  alarm_description   = "This metric monitors CPU utilization"
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_application_autoscaling_group.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.cpu_low_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_low_period
  statistic           = "Average"
  threshold           = var.cpu_low_threshold
  alarm_description   = "This metric monitors CPU utilization"
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_application_autoscaling_group.name
  }
}

