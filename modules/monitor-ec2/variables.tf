variable "instances_config" {
  description = "Map of instances with config"
  type = map(object({
    project              = optional(string)
    severity             = optional(string)
    cpu_threshold        = optional(number)
    memory_threshold     = optional(number)
    disk_threshold       = optional(number)
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

# Global Enable Flags
variable "enable_cpu" {
  type    = bool
  default = true
}
variable "enable_memory" {
  type    = bool
  default = true
}
variable "enable_disk" {
  type    = bool
  default = true
}
variable "enable_network_in" {
  type    = bool
  default = true
}
variable "enable_network_out" {
  type    = bool
  default = true
}
variable "enable_status_check" {
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
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
