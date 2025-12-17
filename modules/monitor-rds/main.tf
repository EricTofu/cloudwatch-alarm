module "cpu_alarm" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}rds-${each.key}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.cpu_threshold, var.cpu_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}CPU too high on RDS ${each.key} (Threshold: ${coalesce(each.value.cpu_threshold, var.cpu_threshold)}%)"
  alarm_actions       = [var.alarm_sns_topic_critical]
  ok_actions          = [var.alarm_sns_topic_critical]

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.cpu_threshold, var.cpu_threshold))
    Severity = "critical"
  })
}

module "free_storage_space" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}rds-${each.key}-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = coalesce(each.value.free_storage_threshold, var.free_storage_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}Storage low on RDS ${each.key} (Threshold: ${coalesce(each.value.free_storage_threshold, var.free_storage_threshold)})"
  alarm_actions       = [var.alarm_sns_topic_warning]
  ok_actions          = [var.alarm_sns_topic_warning]

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.free_storage_threshold, var.free_storage_threshold))
    Severity = "warning"
  })
}

module "database_connections" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}rds-${each.key}-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.connections_threshold, var.connections_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High database connections on RDS ${each.key} (Threshold: ${coalesce(each.value.connections_threshold, var.connections_threshold)})"
  alarm_actions       = [var.alarm_sns_topic_warning]
  ok_actions          = [var.alarm_sns_topic_warning]

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.connections_threshold, var.connections_threshold))
    Severity = "warning"
  })
}

module "read_latency" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}rds-${each.key}-high-read-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.read_latency_threshold, var.read_latency_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High read latency on RDS ${each.key} (Threshold: ${coalesce(each.value.read_latency_threshold, var.read_latency_threshold)}s)"
  alarm_actions       = [var.alarm_sns_topic_warning]
  ok_actions          = [var.alarm_sns_topic_warning]

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  tags = merge(var.tags, {
    Severity = "warning"
  })
}

module "write_latency" {
  source = "../common-alarm"

  for_each = var.instances_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}rds-${each.key}-high-write-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.write_latency_threshold, var.write_latency_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High write latency on RDS ${each.key} (Threshold: ${coalesce(each.value.write_latency_threshold, var.write_latency_threshold)}s)"
  alarm_actions       = [var.alarm_sns_topic_warning]
  ok_actions          = [var.alarm_sns_topic_warning]

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  tags = merge(var.tags, {
    Severity = "warning"
  })
}
