resource "aws_sns_topic" "lambda_invoke_task" {
  name = "rcv-lambda-invoke-task"
}

resource "aws_sns_topic_subscription" "lambda_invoke_task" {
  topic_arn = aws_sns_topic.lambda_invoke_task.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.start_task.arn
}