variable "apis_config" {
  description = "Map of APIs with config"
  type = map(object({
    error_5xx_threshold = optional(number)
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


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
