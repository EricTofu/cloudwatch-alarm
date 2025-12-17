variable "instances_config" {
  description = "Map of RDS instances with config"
  type = map(object({
    cpu_threshold          = optional(number)
    severity               = optional(string)
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

variable "project" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "cpu_threshold" {}
variable "free_storage_threshold" {}
variable "connections_threshold" {}
variable "read_latency_threshold" {}
variable "write_latency_threshold" {}
variable "period" {}
variable "eval_periods" {}

# Global Enable Flags
variable "enable_cpu" {
  type    = bool
  default = true
}
variable "enable_free_storage" {
  type    = bool
  default = true
}
variable "enable_connections" {
  type    = bool
  default = true
}
variable "enable_read_latency" {
  type    = bool
  default = true
}
variable "enable_write_latency" {
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
  default     = "" # Optional if logic handles empty, but better to enforce or use null
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
