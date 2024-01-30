resource "aws_lambda_function" "start_task" {
  filename         = data.archive_file.start_task.output_path
  function_name    = "rcv-start-task"
  handler          = "main.lambda_handler"
  role             = aws_iam_role.start_task_lambda.arn
  runtime          = "python3.10"
  source_code_hash = data.archive_file.start_task.output_base64sha256
  tags = {
    Name = "rcv-start-task"
  }

  environment {
    variables = {
      CLUSTER_ARN         = aws_ecs_cluster.rcv.arn
      SUBNET_ID           = var.subnet_id
      TASK_DEFINITION_ARN = aws_ecs_task_definition.rcv.arn
    }
  }
}


data "archive_file" "start_task" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/start-task"
  output_path = "${path.root}/lambda/zip/start-task.zip"
}

resource "aws_lambda_permission" "start_task" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_task.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.lambda_invoke_task.arn
}