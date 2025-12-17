variable "apis_config" {
  description = "Map of APIs with config"
  type = map(object({
    error_5xx_threshold = optional(number)
    severity            = optional(string)
    latency_threshold   = optional(number)
    period              = optional(number)
    eval_periods        = optional(number)
  }))
  default = {}
}

variable "project" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "error_5xx_threshold" {}
variable "latency_threshold" {}
variable "period" {}
variable "eval_periods" {}

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
