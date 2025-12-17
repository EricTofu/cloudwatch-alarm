# Fetch instance details (specifically Tags)
data "aws_instance" "this" {
  for_each    = var.instances_config
  instance_id = each.key
}

locals {
  # Map ID -> "Name tag" OR "ID" (fallback)
  instance_names = {
    for id, config in var.instances_config :
    id => try(data.aws_instance.this[id].tags["Name"], id)
  }
  
  # Alarm name prefix with optional project
  alarm_prefix = var.project != "" ? "${var.project}-ec2" : "ec2"
}

module "cpu_alarm" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${each.value.project != null ? "${each.value.project}-ec2" : local.alarm_prefix}-${local.instance_names[each.key]}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.cpu_threshold, var.cpu_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}CPU too high on ${local.instance_names[each.key]} (${each.key}) (Threshold: ${coalesce(each.value.cpu_threshold, var.cpu_threshold)}%)"
  alarm_actions       = [
    each.value.severity == "warning" ? var.alarm_sns_topic_warning :
    each.value.severity == "info"    ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_critical  # Default: critical
  ]
  ok_actions          = [
    each.value.severity == "warning" ? var.alarm_sns_topic_warning :
    each.value.severity == "info"    ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_critical
  ]

  dimensions = {
    InstanceId = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.cpu_threshold, var.cpu_threshold))
    Severity = "critical"
  })
}

# Memory monitoring (requires CloudWatch Agent)
module "memory_alarm" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${each.value.project != null ? "${each.value.project}-ec2" : local.alarm_prefix}-${local.instance_names[each.key]}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.memory_threshold, var.memory_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}Memory too high on ${local.instance_names[each.key]} (${each.key}) (Threshold: ${coalesce(each.value.memory_threshold, var.memory_threshold)}%)"
  alarm_actions       = [
    each.value.severity == "critical" ? var.alarm_sns_topic_critical :
    each.value.severity == "info"     ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_warning  # Default: warning
  ]
  ok_actions          = [
    each.value.severity == "critical" ? var.alarm_sns_topic_critical :
    each.value.severity == "info"     ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_warning
  ]

  dimensions = {
    InstanceId = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.memory_threshold, var.memory_threshold))
    Severity = "warning"
  })
}

# Disk monitoring (requires CloudWatch Agent)
module "disk_alarm" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${each.value.project != null ? "${each.value.project}-ec2" : local.alarm_prefix}-${local.instance_names[each.key]}-high-disk"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.disk_threshold, var.disk_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}Disk usage too high on ${local.instance_names[each.key]} (${each.key}) (Threshold: ${coalesce(each.value.disk_threshold, var.disk_threshold)}%)"
  alarm_actions       = [
    each.value.severity == "critical" ? var.alarm_sns_topic_critical :
    each.value.severity == "info"     ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_warning  # Default: warning
  ]
  ok_actions          = [
    each.value.severity == "critical" ? var.alarm_sns_topic_critical :
    each.value.severity == "info"     ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_warning
  ]

  dimensions = {
    InstanceId = each.key
    path       = "/"
    fstype     = "ext4"
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.disk_threshold, var.disk_threshold))
    Severity = "warning"
  })
}

# Network In monitoring
module "network_in_alarm" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${each.value.project != null ? "${each.value.project}-ec2" : local.alarm_prefix}-${local.instance_names[each.key]}-high-network-in"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.network_in_threshold, var.network_in_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}Network In too high on ${local.instance_names[each.key]} (${each.key})"
  alarm_actions       = [
    each.value.severity == "critical" ? var.alarm_sns_topic_critical :
    each.value.severity == "warning"  ? var.alarm_sns_topic_warning :
    var.alarm_sns_topic_info  # Default: info
  ]
  ok_actions          = [
    each.value.severity == "critical" ? var.alarm_sns_topic_critical :
    each.value.severity == "warning"  ? var.alarm_sns_topic_warning :
    var.alarm_sns_topic_info
  ]

  dimensions = {
    InstanceId = each.key
  }

  tags = merge(var.tags, {
    Severity = "info"
  })
}

# Network Out monitoring
module "network_out_alarm" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${each.value.project != null ? "${each.value.project}-ec2" : local.alarm_prefix}-${local.instance_names[each.key]}-high-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.network_out_threshold, var.network_out_threshold)
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}Network Out too high on ${local.instance_names[each.key]} (${each.key})"
  alarm_actions       = [
    each.value.severity == "critical" ? var.alarm_sns_topic_critical :
    each.value.severity == "warning"  ? var.alarm_sns_topic_warning :
    var.alarm_sns_topic_info  # Default: info
  ]
  ok_actions          = [
    each.value.severity == "critical" ? var.alarm_sns_topic_critical :
    each.value.severity == "warning"  ? var.alarm_sns_topic_warning :
    var.alarm_sns_topic_info
  ]

  dimensions = {
    InstanceId = each.key
  }

  tags = merge(var.tags, {
    Severity = "info"
  })
}

module "status_check_failed" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${each.value.project != null ? "${each.value.project}-ec2" : local.alarm_prefix}-${local.instance_names[each.key]}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "${each.value.project != null ? "[${each.value.project}] " : (var.project != "" ? "[${var.project}] " : "")}Status check failed on ${local.instance_names[each.key]} (${each.key})"
  alarm_actions       = [
    each.value.severity == "warning" ? var.alarm_sns_topic_warning :
    each.value.severity == "info"    ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_critical  # Default: critical
  ]
  ok_actions          = [
    each.value.severity == "warning" ? var.alarm_sns_topic_warning :
    each.value.severity == "info"    ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_critical
  ]

  dimensions = {
    InstanceId = each.key
  }

  tags = merge(var.tags, {
    Severity = "critical"
  })
}
