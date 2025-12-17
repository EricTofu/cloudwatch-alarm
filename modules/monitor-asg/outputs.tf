output "alarm_arns" {
  description = "ARNs of the created alarms"
  value = concat(
    [for alarm in aws_cloudwatch_metric_alarm.high_cpu : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.status_check_failed : alarm.arn]
  )
}
