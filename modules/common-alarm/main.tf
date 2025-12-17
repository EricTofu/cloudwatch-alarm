resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.alarm_name
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  threshold           = var.threshold
  alarm_description   = var.alarm_description
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = var.treat_missing_data
  
  # Standard Metric Config (Mutually Exclusive with metric_query)
  metric_name = length(var.metric_queries) == 0 ? var.metric_name : null
  namespace   = length(var.metric_queries) == 0 ? var.namespace : null
  period      = length(var.metric_queries) == 0 ? var.period : null
  statistic   = length(var.metric_queries) == 0 ? var.statistic : null
  dimensions  = length(var.metric_queries) == 0 ? var.dimensions : null

  # Dynamic Metric Query
  dynamic "metric_query" {
    for_each = var.metric_queries
    content {
      id          = metric_query.value.id
      expression  = try(metric_query.value.expression, null)
      label       = try(metric_query.value.label, null)
      return_data = try(metric_query.value.return_data, null)

      dynamic "metric" {
        for_each = try(metric_query.value.metric, null) != null ? [metric_query.value.metric] : []
        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = try(metric.value.unit, null)
          dimensions  = try(metric.value.dimensions, null)
        }
      }
    }
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}
