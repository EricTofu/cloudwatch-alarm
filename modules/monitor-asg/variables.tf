variable "auto_scaling_groups" {
  description = "Map of ASG names to their configuration"
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
  }))
  default = {}
}

variable "cpu_threshold" {
  description = "Default CPU utilization threshold (percent)"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Default Memory utilization threshold (percent)"
  type        = number
  default     = 80
}

variable "disk_threshold" {
  description = "Default Disk utilization threshold (percent)"
  type        = number
  default     = 80
}

variable "network_in_threshold" {
  description = "Default Network In threshold (bytes/sec)"
  type        = number
  default     = 500000000
}

variable "network_out_threshold" {
  description = "Default Network Out threshold (bytes/sec)"
  type        = number
  default     = 500000000
}

variable "period" {
  description = "Default evaluation period (seconds)"
  type        = number
  default     = 300
}

variable "eval_periods" {
  description = "Default number of evaluation periods"
  type        = number
  default     = 1
}

variable "alarm_sns_topic_critical" {
  description = "SNS topic ARN for critical alarms"
  type        = string
}

variable "alarm_sns_topic_warning" {
  description = "SNS topic ARN for warning alarms"
  type        = string
  default     = null
}

variable "alarm_sns_topic_info" {
  description = "SNS topic ARN for info alarms"
  type        = string
  default     = null
}


variable "project" {
  description = "Project name to use as prefix for alarms"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}
