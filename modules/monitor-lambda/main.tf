module "error_alarm" {
  source = "../common-alarm"

  for_each = var.functions_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}lambda-${each.key}-high-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Sum"
  threshold           = coalesce(each.value.error_threshold, var.error_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}Lambda ${each.key} errors (Threshold: ${coalesce(each.value.error_threshold, var.error_threshold)})"
  alarm_actions       = [var.alarm_sns_topic_critical]
  ok_actions          = [var.alarm_sns_topic_critical]

  dimensions = {
    FunctionName = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.error_threshold, var.error_threshold))
    Severity = "critical"
  })
}

module "throttles_alarm" {
  source = "../common-alarm"

  for_each = var.functions_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}lambda-${each.key}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Sum"
  threshold           = coalesce(each.value.throttle_threshold, var.throttle_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}Lambda ${each.key} throttles (Threshold: ${coalesce(each.value.throttle_threshold, var.throttle_threshold)})"
  alarm_actions       = [var.alarm_sns_topic_critical]
  ok_actions          = [var.alarm_sns_topic_critical]

  dimensions = {
    FunctionName = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.throttle_threshold, var.throttle_threshold))
    Severity = "critical"
  })
}

module "duration_alarm" {
  source = "../common-alarm"

  for_each = var.functions_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}lambda-${each.key}-high-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.duration_threshold, var.duration_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}Lambda ${each.key} duration approaching timeout (Threshold: ${coalesce(each.value.duration_threshold, var.duration_threshold)}ms)"
  alarm_actions       = [var.alarm_sns_topic_warning]
  ok_actions          = [var.alarm_sns_topic_warning]

  dimensions = {
    FunctionName = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.duration_threshold, var.duration_threshold))
    Severity = "warning"
  })
}

module "concurrent_executions_alarm" {
  source = "../common-alarm"

  for_each = var.functions_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}lambda-${each.key}-high-concurrency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Maximum"
  threshold           = coalesce(each.value.concurrent_executions_threshold, var.concurrent_executions_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}Lambda ${each.key} concurrent executions approaching limit (Threshold: ${coalesce(each.value.concurrent_executions_threshold, var.concurrent_executions_threshold)})"
  alarm_actions       = [var.alarm_sns_topic_warning]
  ok_actions          = [var.alarm_sns_topic_warning]

  dimensions = {
    FunctionName = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.concurrent_executions_threshold, var.concurrent_executions_threshold))
    Severity = "warning"
  })
}
