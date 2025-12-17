variable "ENV" {
  description = "Environment: dev, stg, or prod"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prod"], var.ENV)
    error_message = "ENV must be dev, stg, or prod"
  }
}

variable "project" {
  description = "Project name (e.g., api, web, data-pipeline)"
  type        = string
  default     = ""
}

variable "aws_profile" {
  description = "AWS CLI profile name (must match ENV)"
  type        = string
}

variable "environment_profile_map" {
  description = "Expected AWS profile per environment"
  type        = map(string)
  default = {
    dev  = "dev-profile"
    stg  = "staging-profile"
    prod = "production-profile"
  }
}



variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "alarm_email" {
  description = "Email address for SNS subscription (legacy, use alarm_emails for multiple)"
  type        = string
  default     = null
}

variable "alarm_emails" {
  description = "Map of severity level to email addresses for SNS subscriptions"
  type = object({
    critical = optional(list(string), [])
    warning  = optional(list(string), [])
    info     = optional(list(string), [])
  })
  default = {
    critical = []
    warning  = []
    info     = []
  }
}

variable "sns_topic_arns" {
  description = "Existing SNS Topic ARNs to use instead of creating new ones. Key: critical, warning, info"
  type        = map(string)
  default     = {}
}

# --- Service Configurations ---

# EC2
variable "ec2_instances" {
  description = "Map of EC2 instances to monitor. Key=ID, Value=Config"
  type = map(object({
    project              = optional(string)
    severity             = optional(string)  # Override severity: "critical", "warning", or "info"
    cpu_threshold        = optional(number)
    memory_threshold     = optional(number)
    disk_threshold       = optional(number)
    disk_path            = optional(string)
    disk_device          = optional(string)
    disk_fstype          = optional(string)
    network_in_threshold = optional(number)
    network_out_threshold = optional(number)

    period               = optional(number)
    eval_periods         = optional(number)
    enable_cpu              = optional(bool)
    enable_memory           = optional(bool)
    enable_disk             = optional(bool)
    enable_network_in       = optional(bool)
    enable_network_out      = optional(bool)
    enable_status_check     = optional(bool)
  }))
  default = {}
}

variable "ec2_cpu_threshold" { 
  default = 80
  validation {
    condition     = var.ec2_cpu_threshold >= 0 && var.ec2_cpu_threshold <= 100
    error_message = "CPU threshold must be between 0 and 100"
  }
}
variable "ec2_memory_threshold" { default = 80 }
variable "ec2_disk_threshold" { default = 80 }
variable "ec2_disk_path" { default = "/" }
variable "ec2_disk_device" { default = "nvme0n1p1" }
variable "ec2_disk_fstype" { default = "ext4" }
variable "ec2_network_in_threshold" { default = 100000000 }  # 100MB/s
variable "ec2_network_out_threshold" { default = 100000000 } # 100MB/s
variable "ec2_period" { default = 300 }
variable "ec2_eval_periods" { default = 2 }

# EC2 Enable/Disable Flags
variable "ec2_enable_cpu" { default = true }
variable "ec2_enable_memory" { default = true }
variable "ec2_enable_disk" { default = true }
variable "ec2_enable_network_in" { default = true }
variable "ec2_enable_network_out" { default = true }
variable "ec2_enable_status_check" { default = true }

# Auto Scaling Groups
variable "auto_scaling_groups" {
  description = "Configuration for Auto Scaling Group monitoring"
  type = map(object({
    project                = optional(string)
    severity               = optional(string)
    cpu_threshold          = optional(number)
    memory_threshold       = optional(number)
    disk_threshold         = optional(number)
    network_in_threshold   = optional(number)
    network_out_threshold  = optional(number)
    status_check_threshold = optional(number)
    period                 = optional(number)
    eval_periods           = optional(number)
    enable_cpu              = optional(bool)
    enable_memory           = optional(bool)
    enable_disk             = optional(bool)
    enable_network_in       = optional(bool)
    enable_network_out      = optional(bool)
    enable_status_check     = optional(bool)
  }))
  default = {}
}

variable "asg_cpu_threshold" {
  description = "Default CPU threshold for ASG alarms"
  type        = number
  default     = 80
}

variable "asg_memory_threshold" {
  description = "Default Memory threshold for ASG alarms"
  type        = number
  default     = 80
}

variable "asg_disk_threshold" {
  description = "Default Disk threshold for ASG alarms"
  type        = number
  default     = 80
}

variable "asg_network_in_threshold" {
  description = "Default Network In threshold for ASG alarms (bytes/sec)"
  type        = number
  default     = 500000000 # 500MB/s (High defaults to avoid noise, adjust as needed)
}

variable "asg_network_out_threshold" {
  description = "Default Network Out threshold for ASG alarms (bytes/sec)"
  type        = number
  default     = 500000000 # 500MB/s
}

variable "asg_period" {
  description = "Default period for ASG alarms"
  type        = number
  default     = 300
}

variable "asg_eval_periods" {
  description = "Default evaluation periods for ASG alarms"
  type        = number
  default     = 1
}

# ASG Enable/Disable Flags
variable "asg_enable_cpu" { default = true }
variable "asg_enable_memory" { default = true }
variable "asg_enable_disk" { default = true }
variable "asg_enable_network_in" { default = true }
variable "asg_enable_network_out" { default = true }
variable "asg_enable_status_check" { default = true }

# RDS
variable "rds_instances" {
  description = "Map of RDS instances to monitor. Key=ID, Value=Config"
  type = map(object({
    cpu_threshold          = optional(number)
    free_storage_threshold = optional(number)
    connections_threshold  = optional(number)
    read_latency_threshold = optional(number)
    write_latency_threshold = optional(number)
    period                 = optional(number)
    eval_periods           = optional(number)
    enable_cpu                = optional(bool)
    enable_free_storage       = optional(bool)
    enable_connections        = optional(bool)
    enable_read_latency       = optional(bool)
    enable_write_latency      = optional(bool)
  }))
  default = {}
}
variable "rds_cpu_threshold" { default = 80 }
variable "rds_free_storage_threshold" { default = 5000000000 }
variable "rds_connections_threshold" { default = 80 }  # Percentage of max_connections
variable "rds_read_latency_threshold" { default = 0.01 }  # 10ms
variable "rds_write_latency_threshold" { default = 0.01 } # 10ms
variable "rds_period" { default = 300 }
variable "rds_eval_periods" { default = 2 }

# RDS Enable/Disable Flags
variable "rds_enable_cpu" { default = true }
variable "rds_enable_free_storage" { default = true }
variable "rds_enable_connections" { default = true }
variable "rds_enable_read_latency" { default = true }
variable "rds_enable_write_latency" { default = true }

# Lambda
variable "lambda_functions" {
  description = "Map of Lambda functions to monitor. Key=Name, Value=Config"
  type = map(object({
    error_threshold    = optional(number)
    throttle_threshold = optional(number)
    duration_threshold = optional(number)
    concurrent_executions_threshold = optional(number)
    period             = optional(number)
    eval_periods       = optional(number)
    enable_errors                   = optional(bool)
    enable_throttles                = optional(bool)
    enable_duration                 = optional(bool)
    enable_concurrent_executions    = optional(bool)
  }))
  default = {}
}
variable "lambda_error_threshold" { default = 0 }
variable "lambda_throttle_threshold" { default = 0 }
variable "lambda_duration_threshold" { default = 25000 }  # 25 seconds (approaching 30s timeout)
variable "lambda_concurrent_executions_threshold" { default = 900 }  # 90% of default 1000 limit
variable "lambda_period" { default = 60 }
variable "lambda_eval_periods" { default = 1 }

# Lambda Enable/Disable Flags
variable "lambda_enable_errors" { default = true }
variable "lambda_enable_throttles" { default = true }
variable "lambda_enable_duration" { default = true }
variable "lambda_enable_concurrent_executions" { default = true }

# ALB
variable "albs" {
  description = "Map of ALBs to monitor. Key=Name (not suffix), Value=Config"
  type = map(object({
    htt_5xx_threshold = optional(number)
    period            = optional(number)
    eval_periods      = optional(number)
    enable_alb_5xx    = optional(bool)
  }))
  default = {}
}
variable "target_groups" {
  description = "Map of Target Groups to monitor. Key=Name (not suffix), Value=Config"
  type = map(object({
    htt_5xx_threshold = optional(number)
    period            = optional(number)
    eval_periods      = optional(number)
    enable_target_group_5xx = optional(bool)
  }))
  default = {}
}
variable "alb_5xx_threshold" { default = 0 }
variable "target_group_5xx_threshold" { default = 0 }
variable "alb_period" { default = 60 }
variable "alb_eval_periods" { default = 1 }

# ALB Enable/Disable Flags
variable "alb_enable_5xx" { default = true }
variable "target_group_enable_5xx" { default = true }

# API Gateway
variable "api_gateways" {
  description = "Map of APIs to monitor. Key=Name, Value=Config"
  type = map(object({
    error_5xx_threshold = optional(number)
    latency_threshold   = optional(number)
    period              = optional(number)
    eval_periods        = optional(number)
    enable_5xx          = optional(bool)
    enable_latency      = optional(bool)
  }))
  default = {}
}
variable "api_gateway_5xx_threshold" { default = 0 }
variable "api_gateway_latency_threshold" { default = 1000 }
variable "api_gateway_period" { default = 60 }
variable "api_gateway_eval_periods" { default = 1 }

# API Gateway Enable/Disable Flags
variable "api_gateway_enable_5xx" { default = true }
variable "api_gateway_enable_latency" { default = true }

# S3
variable "s3_buckets" {
  description = "Map of S3 buckets to monitor. Key=Name, Value=Config"
  type = map(object({
    error_4xx_threshold = optional(number)
    error_5xx_threshold = optional(number)
    period              = optional(number)
    eval_periods        = optional(number)
    enable_4xx          = optional(bool)
    enable_5xx          = optional(bool)
  }))
  default = {}
}
variable "s3_4xx_threshold" { default = 10 }
variable "s3_5xx_threshold" { default = 0 }
variable "s3_period" { default = 86400 }
variable "s3_eval_periods" { default = 1 }

# S3 Enable/Disable Flags
variable "s3_enable_4xx" { default = true }
variable "s3_enable_5xx" { default = true }
