# API Gateway DynamoDB integration
resource "aws_iam_role" "api_gateway_dynamodb" {
  name = "ServiceRoleFor${title(var.name)}ApiGatewayDynamoDB"
  tags = {
    Name = var.name
  }
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "apigateway.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "RcvApiGatewayDynamoDBRolePolicy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" = "DynamoDBQuery",
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:Query"
          ],
          "Resource" : aws_dynamodb_table.rcv.arn
        }
      ]
    })
  }
}