provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  
  default_tags {
    tags = merge(var.tags, {
      Environment = var.ENV
      Project     = var.project
      ManagedBy   = "Terraform"
    })
  }
}

# Validate profile matches environment
locals {
  expected_profile = var.environment_profile_map[var.ENV]
  profile_matches  = var.aws_profile == local.expected_profile
}

resource "null_resource" "profile_validation" {
  lifecycle {
    precondition {
      condition     = local.profile_matches
      error_message = "Profile mismatch! Environment '${var.ENV}' requires profile '${local.expected_profile}' but got '${var.aws_profile}'"
    }
  }
}

# SNS Topics for different severity levels
# Only create if valid ARN is not provided in var.sns_topic_arns

resource "aws_sns_topic" "alerts_critical" {
  count = lookup(var.sns_topic_arns, "critical", null) == null ? 1 : 0
  name  = "cloudwatch-alerts-critical-${var.ENV}"
}

resource "aws_sns_topic" "alerts_warning" {
  count = lookup(var.sns_topic_arns, "warning", null) == null ? 1 : 0
  name  = "cloudwatch-alerts-warning-${var.ENV}"
}

resource "aws_sns_topic" "alerts_info" {
  count = lookup(var.sns_topic_arns, "info", null) == null ? 1 : 0
  name  = "cloudwatch-alerts-info-${var.ENV}"
}

# Legacy single topic for backward compatibility
resource "aws_sns_topic" "alerts" {
  count = var.alarm_email != null ? 1 : 0
  name  = "cloudwatch-alerts-topic-${var.ENV}"
}

locals {
  # Resolve Topic ARNs: Use existing if provided, else use created
  critical_topic_arn = lookup(var.sns_topic_arns, "critical", null) != null ? var.sns_topic_arns["critical"] : aws_sns_topic.alerts_critical[0].arn
  warning_topic_arn  = lookup(var.sns_topic_arns, "warning", null) != null ? var.sns_topic_arns["warning"] : aws_sns_topic.alerts_warning[0].arn
  info_topic_arn     = lookup(var.sns_topic_arns, "info", null) != null ? var.sns_topic_arns["info"] : aws_sns_topic.alerts_info[0].arn
  legacy_topic_arn   = var.alarm_email != null ? aws_sns_topic.alerts[0].arn : null
}

# Email subscriptions for critical alerts
resource "aws_sns_topic_subscription" "critical_email" {
  for_each  = toset(var.alarm_emails.critical)
  topic_arn = local.critical_topic_arn
  protocol  = "email"
  endpoint  = each.value
}

# Email subscriptions for warning alerts
resource "aws_sns_topic_subscription" "warning_email" {
  for_each  = toset(var.alarm_emails.warning)
  topic_arn = local.warning_topic_arn
  protocol  = "email"
  endpoint  = each.value
}

# Email subscriptions for info alerts
resource "aws_sns_topic_subscription" "info_email" {
  for_each  = toset(var.alarm_emails.info)
  topic_arn = local.info_topic_arn
  protocol  = "email"
  endpoint  = each.value
}

# Legacy email subscription
resource "aws_sns_topic_subscription" "email_alerts" {
  count     = var.alarm_email != null ? 1 : 0
  topic_arn = local.legacy_topic_arn
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
  disk_path              = var.ec2_disk_path
  disk_device            = var.ec2_disk_device
  disk_fstype            = var.ec2_disk_fstype
  network_in_threshold   = var.ec2_network_in_threshold
  network_out_threshold  = var.ec2_network_out_threshold
  period                 = var.ec2_period
  eval_periods           = var.ec2_eval_periods
  alarm_sns_topic_critical = local.critical_topic_arn
  alarm_sns_topic_warning  = local.warning_topic_arn
  alarm_sns_topic_info     = local.info_topic_arn
  enable_cpu              = var.ec2_enable_cpu
  enable_memory           = var.ec2_enable_memory
  enable_disk             = var.ec2_enable_disk
  enable_network_in       = var.ec2_enable_network_in
  enable_network_out      = var.ec2_enable_network_out
  enable_status_check     = var.ec2_enable_status_check
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
  alarm_sns_topic_critical = local.critical_topic_arn
  alarm_sns_topic_warning  = local.warning_topic_arn
  alarm_sns_topic_info     = local.info_topic_arn
  enable_cpu                = var.rds_enable_cpu
  enable_free_storage       = var.rds_enable_free_storage
  enable_connections        = var.rds_enable_connections
  enable_read_latency       = var.rds_enable_read_latency
  enable_write_latency      = var.rds_enable_write_latency
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
  alarm_sns_topic_critical = local.critical_topic_arn
  alarm_sns_topic_warning  = local.warning_topic_arn
  alarm_sns_topic_info     = local.info_topic_arn
  enable_errors                 = var.lambda_enable_errors
  enable_throttles              = var.lambda_enable_throttles
  enable_duration               = var.lambda_enable_duration
  enable_concurrent_executions  = var.lambda_enable_concurrent_executions
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
  alarm_sns_topic_critical = local.critical_topic_arn
  alarm_sns_topic_warning  = local.warning_topic_arn
  alarm_sns_topic_info     = local.info_topic_arn
  enable_alb_5xx            = var.alb_enable_5xx
  enable_target_group_5xx   = var.target_group_enable_5xx
}

module "monitor_apigateway" {
  source = "./modules/monitor-apigateway"

  project             = var.project
  apis_config         = var.api_gateways
  error_5xx_threshold = var.api_gateway_5xx_threshold
  latency_threshold   = var.api_gateway_latency_threshold
  period              = var.api_gateway_period
  eval_periods        = var.api_gateway_eval_periods
  alarm_sns_topic_critical = local.critical_topic_arn
  alarm_sns_topic_warning  = local.warning_topic_arn
  alarm_sns_topic_info     = local.info_topic_arn
  enable_5xx                = var.api_gateway_enable_5xx
  enable_latency            = var.api_gateway_enable_latency
}

module "monitor_s3" {
  source = "./modules/monitor-s3"

  project             = var.project
  buckets_config      = var.s3_buckets
  error_4xx_threshold = var.s3_4xx_threshold
  error_5xx_threshold = var.s3_5xx_threshold
  period              = var.s3_period
  eval_periods        = var.s3_eval_periods
  alarm_sns_topic_critical = local.critical_topic_arn
  alarm_sns_topic_warning  = local.warning_topic_arn
  alarm_sns_topic_info     = local.info_topic_arn
  enable_4xx                = var.s3_enable_4xx
  enable_5xx                = var.s3_enable_5xx
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
  alarm_sns_topic_critical = local.critical_topic_arn
  alarm_sns_topic_warning  = local.warning_topic_arn
  alarm_sns_topic_info     = local.info_topic_arn
  enable_cpu              = var.asg_enable_cpu
  enable_memory           = var.asg_enable_memory
  enable_disk             = var.asg_enable_disk
  enable_network_in       = var.asg_enable_network_in
  enable_network_out      = var.asg_enable_network_out
  enable_status_check     = var.asg_enable_status_check
}
