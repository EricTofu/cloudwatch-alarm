output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alerts (legacy)"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_critical_arn" {
  description = "ARN of the SNS topic for critical alerts"
  value       = aws_sns_topic.alerts_critical.arn
}

output "sns_topic_warning_arn" {
  description = "ARN of the SNS topic for warning alerts"
  value       = aws_sns_topic.alerts_warning.arn
}

output "sns_topic_info_arn" {
  description = "ARN of the SNS topic for info alerts"
  value       = aws_sns_topic.alerts_info.arn
}
