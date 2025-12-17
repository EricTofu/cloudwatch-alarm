module "error_4xx_alarm" {
  source = "../common-alarm"

  for_each = var.buckets_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}s3-${each.key}-high-4xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Sum"
  threshold           = coalesce(each.value.error_4xx_threshold, var.error_4xx_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High 4XX on S3 ${each.key} (Threshold: ${coalesce(each.value.error_4xx_threshold, var.error_4xx_threshold)})"
  alarm_actions       = [var.alarm_sns_topic_critical]
  ok_actions          = [var.alarm_sns_topic_critical]

  dimensions = {
    BucketName = each.key
    FilterId   = "EntireBucket"
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.error_4xx_threshold, var.error_4xx_threshold))
  })
}

module "error_5xx_alarm" {
  source = "../common-alarm"

  for_each = var.buckets_config

  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}s3-${each.key}-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "5xxErrors"
  namespace           = "AWS/S3"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Sum"
  threshold           = coalesce(each.value.error_5xx_threshold, var.error_5xx_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High 5XX on S3 ${each.key} (Threshold: ${coalesce(each.value.error_5xx_threshold, var.error_5xx_threshold)})"
  alarm_actions       = [var.alarm_sns_topic_critical]
  ok_actions          = [var.alarm_sns_topic_critical]

  dimensions = {
    BucketName = each.key
    FilterId   = "EntireBucket"
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.error_5xx_threshold, var.error_5xx_threshold))
  })
}
