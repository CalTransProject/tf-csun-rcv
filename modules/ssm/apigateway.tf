# REST api for SSM
resource "aws_api_gateway_rest_api" "ssm" {
  name        = "rcv-ssm"
  description = "REST API for rcv ssm access."
  tags = {
    Name = "rcv-ssm"
  }
}

## api resource
resource "aws_api_gateway_resource" "ssm" {
  rest_api_id = aws_api_gateway_rest_api.ssm.id
  parent_id   = aws_api_gateway_rest_api.ssm.root_resource_id
  path_part   = "app"
}

### app/GET method
resource "aws_api_gateway_method" "ssm" {
  rest_api_id   = aws_api_gateway_rest_api.ssm.id
  resource_id   = aws_api_gateway_resource.ssm.id
  http_method   = "GET"
  authorization = "NONE"
}

### app/GET response
resource "aws_api_gateway_method_response" "ssm" {
  rest_api_id = aws_api_gateway_rest_api.ssm.id
  resource_id = aws_api_gateway_resource.ssm.id
  http_method = aws_api_gateway_method.ssm.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

## ssm integration
resource "aws_api_gateway_integration" "ssm" {
  rest_api_id             = aws_api_gateway_rest_api.ssm.id
  resource_id             = aws_api_gateway_resource.ssm.id
  http_method             = aws_api_gateway_method.ssm.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:ssm:action/GetParameter"
  credentials             = aws_iam_role.api_gateway_ssm.arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  request_parameters      = { "integration.request.querystring.Name" = "'/rcv/meta'" }
}

### ssm integration response
resource "aws_api_gateway_integration_response" "ssm" {
  rest_api_id = aws_api_gateway_rest_api.ssm.id
  resource_id = aws_api_gateway_resource.ssm.id
  http_method = aws_api_gateway_method.ssm.http_method
  status_code = aws_api_gateway_method_response.ssm.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET'"
  }
  response_templates = {
    "application/json" = <<-EOF
      #if ($input.path('$').GetParameterResponse.GetParameterResult.Parameter.Value)
      $input.path('$').GetParameterResponse.GetParameterResult.Parameter.Value
      #end
    EOF
  }
  depends_on = [
    aws_api_gateway_integration.ssm
  ]
}

## method settings
resource "aws_api_gateway_method_settings" "ssm" {
  rest_api_id = aws_api_gateway_rest_api.ssm.id
  stage_name  = aws_api_gateway_deployment.ssm.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    throttling_rate_limit  = 100
    throttling_burst_limit = 100
  }
}

## deployment
resource "aws_api_gateway_deployment" "ssm" {
  stage_name  = "rcv"
  rest_api_id = aws_api_gateway_rest_api.ssm.id
  variables = {
    "deployedAt" = timestamp()
  }
  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_api_gateway_resource.ssm),
      jsonencode(aws_api_gateway_method.ssm),
      jsonencode(aws_api_gateway_method_response.ssm),
      jsonencode(aws_api_gateway_integration.ssm),
      jsonencode(aws_api_gateway_integration_response.ssm),
    ])))
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [variables]
  }
}