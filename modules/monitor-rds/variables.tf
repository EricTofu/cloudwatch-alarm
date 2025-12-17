variable "instances_config" {
  description = "Map of RDS instances with config"
  type = map(object({
    cpu_threshold          = optional(number)
    free_storage_threshold = optional(number)
    connections_threshold  = optional(number)
    read_latency_threshold = optional(number)
    write_latency_threshold = optional(number)
    period                 = optional(number)
    eval_periods           = optional(number)
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

variable "alarm_sns_topic_critical" {
  description = "SNS topic ARN for critical alarms"
  type        = string
}

variable "alarm_sns_topic_warning" {
  description = "SNS topic ARN for warning alarms"
  type        = string
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
