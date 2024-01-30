locals {
  image_uri = "${data.aws_caller_identity.this.id}.dkr.ecr.${data.aws_region.this.name}.amazonaws.com/${data.aws_ecr_image.this.repository_name}:${data.aws_ecr_image.this.image_tag}"
}

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

data "aws_ecr_image" "this" {
  repository_name = var.repository_name
  image_tag = var.image_tag
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.this.arn
  package_type = "Image"
  image_uri = local.image_uri
  memory_size = var.memory_size
  timeout = var.timeout
  source_code_hash = trimprefix(data.aws_ecr_image.this.id, "sha256:")
  tags = {
    Name = var.function_name
  }

  environment {
    variables = {
      CONFIDENCE_THRESHOLD=0.1
      NMS_THRESHOLD=0.1
    }
  }
}

data "aws_iam_policy" "this" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "this" {
  name = "${var.function_name}-policy"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17"
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = data.aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_group_retention_in_days
}