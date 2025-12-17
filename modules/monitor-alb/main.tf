# Resolve ARN Suffixes from Names
data "aws_lb_target_group" "this" {
  for_each = var.target_groups_config
  name     = each.key
}

data "aws_lb" "this" {
  for_each = var.albs_config
  name     = each.key
}

module "target_5xx_alarm" {
  source = "../common-alarm"

  for_each = var.target_groups_config

  # Use Friendly Name in Alarm Name
  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}tg-${each.key}-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Sum"
  threshold           = coalesce(each.value.htt_5xx_threshold, var.target_group_5xx_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High 5XX on target group ${each.key} (Threshold: ${coalesce(each.value.htt_5xx_threshold, var.target_group_5xx_threshold)})"
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
    # Resolve the ARN Suffix dynamically
    TargetGroup = data.aws_lb_target_group.this[each.key].arn_suffix
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.htt_5xx_threshold, var.target_group_5xx_threshold))
  })
}

module "alb_5xx_alarm" {
  source = "../common-alarm"

  for_each = var.albs_config

  # Use Friendly Name in Alarm Name
  alarm_name          = "${var.project != "" ? "${var.project}-" : ""}alb-${each.key}-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = coalesce(each.value.eval_periods, var.eval_periods)
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = coalesce(each.value.period, var.period)
  statistic           = "Sum"
  threshold           = coalesce(each.value.htt_5xx_threshold, var.alb_5xx_threshold)
  alarm_description   = "${var.project != "" ? "[${var.project}] " : ""}High 5XX on ALB ${each.key} (Threshold: ${coalesce(each.value.htt_5xx_threshold, var.alb_5xx_threshold)})"
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
    # Resolve the ARN Suffix dynamically
    LoadBalancer = data.aws_lb.this[each.key].arn_suffix
  }

  tags = merge(var.tags, {
    ConfiguredThreshold = tostring(coalesce(each.value.htt_5xx_threshold, var.alb_5xx_threshold))
  })
}
