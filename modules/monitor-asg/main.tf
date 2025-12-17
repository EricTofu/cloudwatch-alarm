locals {
  sns_topic_map = {
    critical = var.alarm_sns_topic_critical
    warning  = coalesce(var.alarm_sns_topic_warning, var.alarm_sns_topic_critical)
    info     = coalesce(var.alarm_sns_topic_info, var.alarm_sns_topic_warning, var.alarm_sns_topic_critical)
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_cpu, var.enable_cpu, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  threshold           = coalesce(each.value.cpu_threshold, var.cpu_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High CPU on any instance in ASG ${each.key} (Threshold: ${coalesce(each.value.cpu_threshold, var.cpu_threshold)}%)"
  treat_missing_data  = "notBreaching"
  
  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "critical")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "critical")]]

  dynamic "metric_query" {
    for_each = [1]
    content {
      id          = "e1"
      expression  = "MAX(SEARCH('{AWS/EC2,InstanceId,AutoScalingGroupName} MetricName=\"CPUUtilization\" \"AutoScalingGroupName\"=\"${each.key}\"', 'Average', ${coalesce(each.value.period, var.period)}))"
      label       = "Max CPU Utilization"
      return_data = true
      period      = coalesce(each.value.period, var.period)
    }
  }

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "critical")
  })
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_status_check, var.enable_status_check, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  threshold           = 0
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}Status check failed on any instance in ASG ${each.key}"
  treat_missing_data  = "notBreaching"
  
  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "critical")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "critical")]]

  dynamic "metric_query" {
    for_each = [1]
    content {
      id          = "e1"
      expression  = "MAX(SEARCH('{AWS/EC2,InstanceId,AutoScalingGroupName} MetricName=\"StatusCheckFailed\" \"AutoScalingGroupName\"=\"${each.key}\"', 'Maximum', ${coalesce(each.value.period, var.period)}))"
      label       = "Max Status Check Failed"
      return_data = true
      period      = coalesce(each.value.period, var.period)
    }
  }

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "critical")
  })
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_memory, var.enable_memory, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  threshold           = coalesce(each.value.memory_threshold, var.memory_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High Memory on any instance in ASG ${each.key} (Threshold: ${coalesce(each.value.memory_threshold, var.memory_threshold)}%)"
  treat_missing_data  = "notBreaching"
  
  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "warning")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "warning")]]

  dynamic "metric_query" {
    for_each = [1]
    content {
      id          = "e1"
      expression  = "MAX(SEARCH('{CWAgent,InstanceId,AutoScalingGroupName} MetricName=\"mem_used_percent\" \"AutoScalingGroupName\"=\"${each.key}\"', 'Average', ${coalesce(each.value.period, var.period)}))"
      label       = "Max Memory Utilization"
      return_data = true
      period      = coalesce(each.value.period, var.period)
    }
  }

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "warning")
  })
}

resource "aws_cloudwatch_metric_alarm" "high_disk" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_disk, var.enable_disk, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-disk"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  threshold           = coalesce(each.value.disk_threshold, var.disk_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High Disk usage on any instance in ASG ${each.key} (Threshold: ${coalesce(each.value.disk_threshold, var.disk_threshold)}%)"
  treat_missing_data  = "notBreaching"
  
  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "warning")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "warning")]]

  dynamic "metric_query" {
    for_each = [1]
    content {
      id          = "e1"
      expression  = "MAX(SEARCH('{CWAgent,InstanceId,AutoScalingGroupName,path,fstype} MetricName=\"disk_used_percent\" \"AutoScalingGroupName\"=\"${each.key}\" \"path\"=\"/\" \"fstype\"=\"ext4\"', 'Average', ${coalesce(each.value.period, var.period)}))"
      label       = "Max Disk Utilization"
      return_data = true
      period      = coalesce(each.value.period, var.period)
    }
  }

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "warning")
  })
}

resource "aws_cloudwatch_metric_alarm" "high_network_in" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_network_in, var.enable_network_in, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-network-in"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  threshold           = coalesce(each.value.network_in_threshold, var.network_in_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High Network In on any instance in ASG ${each.key}"
  treat_missing_data  = "notBreaching"
  
  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "info")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "info")]]

  dynamic "metric_query" {
    for_each = [1]
    content {
      id          = "e1"
      expression  = "MAX(SEARCH('{AWS/EC2,InstanceId,AutoScalingGroupName} MetricName=\"NetworkIn\" \"AutoScalingGroupName\"=\"${each.key}\"', 'Average', ${coalesce(each.value.period, var.period)}))"
      label       = "Max Network In"
      return_data = true
      period      = coalesce(each.value.period, var.period)
    }
  }

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "info")
  })
}

resource "aws_cloudwatch_metric_alarm" "high_network_out" {
  for_each = {
    for k, v in var.auto_scaling_groups : k => v
    if coalesce(v.enable_network_out, var.enable_network_out, true)
  }

  alarm_name          = "${each.value.project != null ? "${each.value.project}-" : (var.project != "" ? "${var.project}-" : "")}asg-${each.key}-high-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  threshold           = coalesce(each.value.network_out_threshold, var.network_out_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}High Network Out on any instance in ASG ${each.key}"
  treat_missing_data  = "notBreaching"
  
  alarm_actions = [local.sns_topic_map[coalesce(each.value.severity, "info")]]
  ok_actions    = [local.sns_topic_map[coalesce(each.value.severity, "info")]]

  dynamic "metric_query" {
    for_each = [1]
    content {
      id          = "e1"
      expression  = "MAX(SEARCH('{AWS/EC2,InstanceId,AutoScalingGroupName} MetricName=\"NetworkOut\" \"AutoScalingGroupName\"=\"${each.key}\"', 'Average', ${coalesce(each.value.period, var.period)}))"
      label       = "Max Network Out"
      return_data = true
      period      = coalesce(each.value.period, var.period)
    }
  }

  tags = merge(var.tags, {
    Severity = coalesce(each.value.severity, "info")
  })
}
