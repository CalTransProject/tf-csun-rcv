resource "aws_cloudwatch_log_group" "task" {
  name              = "/rcv/task"
  retention_in_days = 7
  tags = {
    Name = "rcv-task"
  }
}

resource "aws_cloudwatch_metric_alarm" "putmedia" {
  alarm_name          = "rcv-putmedia-requests"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "PutMedia.Requests"
  namespace           = "AWS/KinesisVideo"
  period              = "60"
  threshold           = "1"
  statistic           = "Average"
  alarm_description   = "Scale-out rcv task"
  treat_missing_data  = "notBreaching"
  alarm_actions = [
    aws_sns_topic.lambda_invoke_task.arn
  ]
  dimensions = {
    StreamName = var.kvs_name
  }
  tags = {
    Name = "rcv-putmedia-requests"
  }
}
