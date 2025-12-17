locals {
  sns_topic_map = {
    critical = var.alarm_sns_topic_critical
    warning  = coalesce(var.alarm_sns_topic_warning, var.alarm_sns_topic_critical)
    info     = coalesce(var.alarm_sns_topic_info, var.alarm_sns_topic_warning, var.alarm_sns_topic_critical)
  }
}

# CPU - AWS/EC2 (Supports AutoScalingGroupName)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_cpu, var.enable_cpu, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Maximum" # Catch the highest CPU instance in the group
  threshold           = coalesce(each.value.cpu_threshold, var.cpu_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}Max CPU > ${coalesce(each.value.cpu_threshold, var.cpu_threshold)}% in ASG ${each.key}"
  
  dimensions = {
    AutoScalingGroupName = each.key
  }

  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "critical")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "critical")]]

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "critical")
  })
}

# Status Check - AWS/EC2
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_status_check, var.enable_status_check, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}Status Check Failed in ASG ${each.key}"
  
  dimensions = {
    AutoScalingGroupName = each.key
  }

  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "critical")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "critical")]]

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "critical")
  })
}

# Memory - CWAgent (Requires agent to aggregate by AutoScalingGroupName)
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_memory, var.enable_memory, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average" # CWAgent usually pushes Average for ASG dimension
  threshold           = coalesce(each.value.memory_threshold, var.memory_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High Memory in ASG ${each.key}"
  
  dimensions = {
    AutoScalingGroupName = each.key
  }
  
  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "warning")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "warning")]]

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "warning")
  })
}

# Disk - CWAgent
resource "aws_cloudwatch_metric_alarm" "high_disk" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_disk, var.enable_disk, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-disk"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.disk_threshold, var.disk_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High Disk utilization in ASG ${each.key}"
  
  dimensions = {
    AutoScalingGroupName = each.key
    path                 = coalesce(each.value.disk_path, var.disk_path)
    fstype               = coalesce(each.value.disk_fstype, var.disk_fstype)
    device               = coalesce(each.value.disk_device, var.disk_device)
  }

  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "warning")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "warning")]]

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "warning")
  })
}

# Network In - AWS/EC2
resource "aws_cloudwatch_metric_alarm" "high_network_in" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_network_in, var.enable_network_in, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-network-in"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.network_in_threshold, var.network_in_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High Network In ASG ${each.key}"
  
  dimensions = {
    AutoScalingGroupName = each.key
  }

  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "info")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "info")]]

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "info")
  })
}

# Network Out - AWS/EC2
resource "aws_cloudwatch_metric_alarm" "high_network_out" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_network_out, var.enable_network_out, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.network_out_threshold, var.network_out_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High Network Out ASG ${each.key}"
  
  dimensions = {
    AutoScalingGroupName = each.key
  }

  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "info")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "info")]]

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "info")
  })
}
