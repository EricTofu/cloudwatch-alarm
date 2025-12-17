variable "instances_config" {
  description = "Map of instances with config"
  type = map(object({
    project              = optional(string)
    cpu_threshold        = optional(number)
    memory_threshold     = optional(number)
    disk_threshold       = optional(number)
    network_in_threshold = optional(number)
    network_out_threshold = optional(number)
    period               = optional(number)
    eval_periods         = optional(number)
  }))
  default = {}
}

variable "project" {
  description = "Project name for alarm naming"
  type        = string
  default     = ""
}

variable "cpu_threshold" {}
variable "memory_threshold" {}
variable "disk_threshold" {}
variable "network_in_threshold" {}
variable "network_out_threshold" {}
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
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
