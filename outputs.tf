output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alerts (legacy)"
  value       = local.legacy_topic_arn
}

output "sns_topic_critical_arn" {
  description = "ARN of the SNS topic for critical alerts"
  value       = local.critical_topic_arn
}

output "sns_topic_warning_arn" {
  description = "ARN of the SNS topic for warning alerts"
  value       = local.warning_topic_arn
}

output "sns_topic_info_arn" {
  description = "ARN of the SNS topic for info alerts"
  value       = local.info_topic_arn
}
