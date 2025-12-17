module "error_5xx_alarm" {
  source = "../common-alarm"

  for_each = var.apis_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}apigw-${each.key}-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Sum"
  threshold           = coalesce(each.value.error_5xx_threshold, var.error_5xx_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High 5XX on API GW ${each.key} (Threshold: ${coalesce(each.value.error_5xx_threshold, var.error_5xx_threshold)})"
  alarm_actions       = [
    each.value.severity == "warning" ? var.alarm_sns_topic_warning :
    each.value.severity == "info"    ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_critical
  ]
  ok_actions          = [
    each.value.severity == "warning" ? var.alarm_sns_topic_warning :
    each.value.severity == "info"    ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_critical
  ]

  dimensions = {
    ApiName = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.error_5xx_threshold, var.error_5xx_threshold))
  })
}

module "latency_alarm" {
  source = "../common-alarm"

  for_each = var.apis_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}apigw-${each.key}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Average"
  threshold           = coalesce(each.value.latency_threshold, var.latency_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High latency on API GW ${each.key} (Threshold: ${coalesce(each.value.latency_threshold, var.latency_threshold)} ms)"
  alarm_actions       = [
    each.value.severity == "warning" ? var.alarm_sns_topic_warning :
    each.value.severity == "info"    ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_critical
  ]
  ok_actions          = [
    each.value.severity == "warning" ? var.alarm_sns_topic_warning :
    each.value.severity == "info"    ? var.alarm_sns_topic_info :
    var.alarm_sns_topic_critical
  ]

  dimensions = {
    ApiName = each.key
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.latency_threshold, var.latency_threshold))
  })
}
