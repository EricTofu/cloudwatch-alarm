variable "buckets_config" {
  description = "Map of Buckets with config"
  type = map(object({
    error_4xx_threshold = optional(number)
    severity            = optional(string)
    error_5xx_threshold = optional(number)
    period              = optional(number)
    period              = optional(number)
    eval_periods        = optional(number)
    enable_4xx          = optional(bool)
    enable_5xx          = optional(bool)
  }))
  default = {}
}

variable "project" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "error_4xx_threshold" {}
variable "error_5xx_threshold" {}
variable "period" {}
variable "period" {}
variable "eval_periods" {}

# Global Enable Flags
variable "enable_4xx" {
  type    = bool
  default = true
}
variable "enable_5xx" {
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
