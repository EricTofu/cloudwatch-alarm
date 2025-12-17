variable "albs_config" {
  description = "Map of ALBs to monitor. Key is the ALB Name (not suffix)"
  type = map(object({
    htt_5xx_threshold = optional(number)
    severity          = optional(string)
    period            = optional(number)

    eval_periods      = optional(number)
    enable_alb_5xx    = optional(bool)
  }))
  default = {}
}

variable "target_groups_config" {
  description = "Map of Target Groups to monitor. Key is the TG Name (not suffix)"
  type = map(object({
    htt_5xx_threshold = optional(number)
    severity          = optional(string)
    period            = optional(number)

    eval_periods      = optional(number)
    enable_target_group_5xx = optional(bool)
  }))
  default = {}
}

variable "project" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "alb_5xx_threshold" {}
variable "target_group_5xx_threshold" {}
variable "period" {}

variable "eval_periods" {}

# Global Enable Flags
variable "enable_alb_5xx" {
  type    = bool
  default = true
}
variable "enable_target_group_5xx" {
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
