# Amazon ECS task execution role policy
data "aws_iam_policy" "amazon_ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "aws_lambda_basic_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# task role
resource "aws_iam_role" "rcv_task" {
  name = "ServiceRoleForRcvTask"
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" = "sts:AssumeRole"
        "Effect" = "Allow"
        "Principal" = {
          "Service" = "ecs-tasks.amazonaws.com",
        }
      }
    ]
  })
  tags = {
    Name = "rcv-task"
  }

  inline_policy {
    name = "RcvTaskRolePolicy"
    policy = jsonencode({
      "Version" = "2012-10-17",
      "Statement" = [
        {
          "Sid"    = "S3AllowAll",
          "Effect" = "Allow",
          "Action" = [
            "s3:*"
          ],
          "Resource" = [
            "${var.s3_arn}/*"
          ]
        },
        {
          "Sid"    = "S3ListBucket",
          "Effect" = "Allow",
          "Action" = [
            "s3:ListBucket"
          ],
          "Resource" = [
            var.s3_arn
          ]
        },
        {
          "Sid" : "KinesisVideoReadAccess",
          "Effect" : "Allow",
          "Action" : [
            "kinesisvideo:GetDataEndpoint",
            "kinesisvideo:GetMedia"
          ],
          "Resource" : [
            var.kvs_arn
          ]
        },
        {
          "Sid" : "LambdaInvoke",
          "Effect" : "Allow",
          "Action" : [
            "lambda:InvokeFunction",
          ],
          "Resource" : [
            var.lambda_arn
          ]
        },
        {
          "Sid" : "DynamoDBPutItem",
          "Effect" : "Allow",
          "Action" : "dynamodb:PutItem",
          "Resource" : [
            var.dynamodb_arn
          ]
        },
        {
          "Sid" = "SSMReadWriteParameter",
          "Effect" : "Allow",
          "Action" = [
            "ssm:GetParameter*",
            "ssm:PutParameter"
          ]
          "Resource" = [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/rcv/*"
          ]
        }
      ]
    })
  }
}

# Service Role for Fargate task execution
resource "aws_iam_role" "fargate_task_execution" {
  name        = "ServiceRoleForFargateTaskExecution"
  description = "The general Fargate service role for task execution."
  tags = {
    Name = "iam-role-fargate-task-execution"
  }
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" = "sts:AssumeRole"
        "Effect" = "Allow"
        "Principal" = {
          "Service" = "ecs-tasks.amazonaws.com",
        }
      }
    ]
  })
}

# Fargate Role attachments
resource "aws_iam_role_policy_attachment" "fargate_task_execution" {
  for_each = {
    1 = data.aws_iam_policy.amazon_ecs_task_execution_role_policy.arn
  }
  role       = aws_iam_role.fargate_task_execution.name
  policy_arn = each.value
}

resource "aws_iam_role" "start_task_lambda" {
  name = "ServiceRoleForRcvStartTaskLambda"
  tags = {
    Name = "rcv-start-task-lambda"
  }
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" = "sts:AssumeRole"
        "Effect" = "Allow"
        "Principal" = {
          "Service" = "lambda.amazonaws.com",
        }
      }
    ]
  })

  inline_policy {
    name = "RcvStartTaskLambdaPolicyRole"
    policy = jsonencode({
      "Version" = "2012-10-17",
      "Statement" = [
        {
          "Sid"    = "ECSRunTask",
          "Effect" = "Allow",
          "Action" = [
            "ecs:RunTask"
          ],
          "Resource" = [
            aws_ecs_task_definition.rcv.arn
          ]
        },
        {
          "Sid"    = "PassRole",
          "Effect" = "Allow",
          "Action" = [
            "iam:PassRole"
          ],
          "Resource" = [
            aws_iam_role.fargate_task_execution.arn,
            aws_iam_role.rcv_task.arn
          ]
        }
      ]
    })
  }
}

# start task lambda role attachment
resource "aws_iam_role_policy_attachment" "start_task_lambda" {
  for_each = {
    1 = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
  }

  role       = aws_iam_role.start_task_lambda.name
  policy_arn = each.value
}
