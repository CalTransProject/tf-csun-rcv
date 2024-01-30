locals {
  image_uri = "${data.aws_caller_identity.current.id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${data.aws_ecr_image.csun_rcv.repository_name}:${data.aws_ecr_image.csun_rcv.image_tag}"
}

data "aws_ecr_image" "csun_rcv" {
  repository_name = "csun-rcv"
  image_tag = "latest"
}

resource "aws_ecs_cluster" "rcv" {
  name = "rcv"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# integration task definition
resource "aws_ecs_task_definition" "rcv" {
  family                   = "rcv"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.fargate_task_execution.arn
  task_role_arn            = aws_iam_role.rcv_task.arn
  tags = {
    Name = "rcv"
  }
  container_definitions = jsonencode([
    {
      name      = data.aws_ecr_image.csun_rcv.repository_name
      image     = local.image_uri
      essential = true
      cpu       = 1024
      memory    = 2048
      environment = [
        {
          name  = "LOG_LEVEL"
          value = "DEBUG"
        },
        {
          name  = "KVS_STREAM"
          value = var.kvs_name
        },
        {
          name  = "LAMBDA_FUNCTION_NAME"
          value = var.lambda_function_name
        },
        {
          name  = "S3_BUCKET"
          value = var.s3_bucket
        },
        {
          name  = "SSM_PARAMETER"
          value = var.ssm_name
        },
        {
          name  = "DYNAMODB_TABLE"
          value = var.dynamodb_name
        }
      ]
      healthCheck = {
        command  = ["CMD", "wget", "-nv", "-t1", "--spider", "http://localhost/ || exit 1"]
        interval = 10
        timeout  = 5
        retries  = 3
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.task.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "awslogs"
        }
      }
    }
  ])
}