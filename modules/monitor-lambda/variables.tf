variable "functions_config" {
  description = "Map of Lambda functions with config"
  type = map(object({
    error_threshold    = optional(number)
    severity           = optional(string)
    throttle_threshold = optional(number)
    duration_threshold = optional(number)
    concurrent_executions_threshold = optional(number)
    period             = optional(number)
    period             = optional(number)
    eval_periods       = optional(number)
    enable_errors                   = optional(bool)
    enable_throttles                = optional(bool)
    enable_duration                 = optional(bool)
    enable_concurrent_executions    = optional(bool)
  }))
  default = {}
}

variable "project" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "error_threshold" {}
variable "throttle_threshold" {}
variable "duration_threshold" {}
variable "concurrent_executions_threshold" {}
variable "period" {}
variable "period" {}
variable "eval_periods" {}

# Global Enable Flags
variable "enable_errors" {
  type    = bool
  default = true
}
variable "enable_throttles" {
  type    = bool
  default = true
}
variable "enable_duration" {
  type    = bool
  default = true
}
variable "enable_concurrent_executions" {
  type    = bool
  default = true
}

variable "alarm_sns_topic_critical" {
  description = "SNS topic ARN for critical alarms"
  type        = string
}

variable "alarm_sns_topic_warning" {
  description = "SNS topic ARN for warning alarms"
  type        = string
}

variable "alarm_sns_topic_info" {
  description = "SNS topic ARN for info alarms"
  type        = string
  default     = ""
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
