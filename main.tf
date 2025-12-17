provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  
  default_tags {
    tags = merge(var.tags, {
      Environment = var.TF_ENV
      Project     = var.project
      ManagedBy   = "Terraform"
    })
  }
}

# Validate profile matches environment
locals {
  expected_profile = var.environment_profile_map[var.TF_ENV]
  profile_matches  = var.aws_profile == local.expected_profile
}

resource "null_resource" "profile_validation" {
  lifecycle {
    precondition {
      condition     = local.profile_matches
      error_message = "Profile mismatch! Environment '${var.TF_ENV}' requires profile '${local.expected_profile}' but got '${var.aws_profile}'"
    }
  }
}

# SNS Topics for different severity levels
resource "aws_sns_topic" "alerts_critical" {
  name = "cloudwatch-alerts-critical-${var.TF_ENV}"
}

resource "aws_sns_topic" "alerts_warning" {
  name = "cloudwatch-alerts-warning-${var.TF_ENV}"
}

resource "aws_sns_topic" "alerts_info" {
  name = "cloudwatch-alerts-info-${var.TF_ENV}"
}

# Legacy single topic for backward compatibility
resource "aws_sns_topic" "alerts" {
  name = "cloudwatch-alerts-topic-${var.TF_ENV}"
}

# Email subscriptions for critical alerts
resource "aws_sns_topic_subscription" "critical_email" {
  for_each  = toset(var.alarm_emails.critical)
  topic_arn = aws_sns_topic.alerts_critical.arn
  protocol  = "email"
  endpoint  = each.value
}

# Email subscriptions for warning alerts
resource "aws_sns_topic_subscription" "warning_email" {
  for_each  = toset(var.alarm_emails.warning)
  topic_arn = aws_sns_topic.alerts_warning.arn
  protocol  = "email"
  endpoint  = each.value
}

# Email subscriptions for info alerts
resource "aws_sns_topic_subscription" "info_email" {
  for_each  = toset(var.alarm_emails.info)
  topic_arn = aws_sns_topic.alerts_info.arn
  protocol  = "email"
  endpoint  = each.value
}

# Legacy email subscription
resource "aws_sns_topic_subscription" "email_alerts" {
  count     = var.alarm_email != null ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

module "monitor_ec2" {
  source = "./modules/monitor-ec2"

  instances_config       = var.ec2_instances
  project                = var.project
  cpu_threshold          = var.ec2_cpu_threshold
  memory_threshold       = var.ec2_memory_threshold
  disk_threshold         = var.ec2_disk_threshold
  network_in_threshold   = var.ec2_network_in_threshold
  network_out_threshold  = var.ec2_network_out_threshold
  period                 = var.ec2_period
  eval_periods           = var.ec2_eval_periods
  alarm_sns_topic_critical = aws_sns_topic.alerts_critical.arn
  alarm_sns_topic_warning  = aws_sns_topic.alerts_warning.arn
  alarm_sns_topic_info     = aws_sns_topic.alerts_info.arn
}

module "monitor_rds" {
  source = "./modules/monitor-rds"

  project                = var.project
  instances_config       = var.rds_instances
  cpu_threshold          = var.rds_cpu_threshold
  free_storage_threshold = var.rds_free_storage_threshold
  connections_threshold  = var.rds_connections_threshold
  read_latency_threshold = var.rds_read_latency_threshold
  write_latency_threshold = var.rds_write_latency_threshold
  period                 = var.rds_period
  eval_periods           = var.rds_eval_periods
  alarm_sns_topic_critical = aws_sns_topic.alerts_critical.arn
  alarm_sns_topic_warning  = aws_sns_topic.alerts_warning.arn
}

module "monitor_lambda" {
  source = "./modules/monitor-lambda"

  project            = var.project
  functions_config   = var.lambda_functions
  error_threshold    = var.lambda_error_threshold
  throttle_threshold = var.lambda_throttle_threshold
  duration_threshold = var.lambda_duration_threshold
  concurrent_executions_threshold = var.lambda_concurrent_executions_threshold
  period             = var.lambda_period
  eval_periods       = var.lambda_eval_periods
  alarm_sns_topic_critical = aws_sns_topic.alerts_critical.arn
  alarm_sns_topic_warning  = aws_sns_topic.alerts_warning.arn
}

module "monitor_alb" {
  source = "./modules/monitor-alb"

  project                    = var.project
  albs_config                = var.albs
  target_groups_config       = var.target_groups
  alb_5xx_threshold          = var.alb_5xx_threshold
  target_group_5xx_threshold = var.target_group_5xx_threshold
  period                     = var.alb_period
  eval_periods               = var.alb_eval_periods
  alarm_sns_topic_critical = aws_sns_topic.alerts_critical.arn
}

module "monitor_apigateway" {
  source = "./modules/monitor-apigateway"

  project             = var.project
  apis_config         = var.api_gateways
  error_5xx_threshold = var.api_gateway_5xx_threshold
  latency_threshold   = var.api_gateway_latency_threshold
  period              = var.api_gateway_period
  eval_periods        = var.api_gateway_eval_periods
  alarm_sns_topic_critical = aws_sns_topic.alerts_critical.arn
}

module "monitor_s3" {
  source = "./modules/monitor-s3"

  project             = var.project
  buckets_config      = var.s3_buckets
  error_4xx_threshold = var.s3_4xx_threshold
  error_5xx_threshold = var.s3_5xx_threshold
  period              = var.s3_period
  eval_periods        = var.s3_eval_periods
  alarm_sns_topic_critical = aws_sns_topic.alerts_critical.arn
}

module "monitor_asg" {
  source = "./modules/monitor-asg"

  project          = var.project
  auto_scaling_groups = var.auto_scaling_groups
  cpu_threshold    = var.asg_cpu_threshold
  memory_threshold = var.asg_memory_threshold
  disk_threshold   = var.asg_disk_threshold
  network_in_threshold = var.asg_network_in_threshold
  network_out_threshold = var.asg_network_out_threshold
  period           = var.asg_period
  eval_periods     = var.asg_eval_periods
  alarm_sns_topic_critical = aws_sns_topic.alerts_critical.arn
  alarm_sns_topic_warning  = aws_sns_topic.alerts_warning.arn
  alarm_sns_topic_info     = aws_sns_topic.alerts_info.arn
}
