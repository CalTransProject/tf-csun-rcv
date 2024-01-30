# API Gateway SSM integration
resource "aws_iam_role" "api_gateway_ssm" {
  name = "ServiceRoleForRcvApiGatewaySSM"
  tags = {
    Name = "iam-role-rcv-api-gateway-ssm"
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
    name = "RcvApiGatewaySSMRolePolicy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" = "SSMGetParameter",
          "Effect" : "Allow",
          "Action"   = "ssm:GetParameter*",
          "Resource" = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/rcv/*"]
        }
      ]
    })
  }
}