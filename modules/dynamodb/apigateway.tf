##
# DynamoDB API
##

# REST api for dynamodb
resource "aws_api_gateway_rest_api" "dynamodb" {
  name        = var.name
  description = "REST API for rcv DynamoDB access."
  tags = {
    Name = var.name
  }
}

## api resource
resource "aws_api_gateway_resource" "dynamodb" {
  rest_api_id = aws_api_gateway_rest_api.dynamodb.id
  parent_id   = aws_api_gateway_rest_api.dynamodb.root_resource_id
  path_part   = "app"
}

### app/GET method
resource "aws_api_gateway_method" "dynamodb" {
  rest_api_id   = aws_api_gateway_rest_api.dynamodb.id
  resource_id   = aws_api_gateway_resource.dynamodb.id
  http_method   = "GET"
  authorization = "NONE"
}

#### app/GET method response
resource "aws_api_gateway_method_response" "dynamodb" {
  rest_api_id = aws_api_gateway_rest_api.dynamodb.id
  resource_id = aws_api_gateway_resource.dynamodb.id
  http_method = aws_api_gateway_method.dynamodb.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

## dynamodb integration
resource "aws_api_gateway_integration" "dynamodb" {
  rest_api_id             = aws_api_gateway_rest_api.dynamodb.id
  resource_id             = aws_api_gateway_resource.dynamodb.id
  http_method             = aws_api_gateway_method.dynamodb.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/Query"
  credentials             = aws_iam_role.api_gateway_dynamodb.arn
  request_templates = {
    "application/json" = <<EOF
      {
        "TableName": "${aws_dynamodb_table.rcv.name}",
        "KeyConditionExpression": "StreamId = :val",
        "ExpressionAttributeValues": {
          ":val": {
              "N": "$util.escapeJavaScript($input.params().querystring.get('sid'))"
          }
        }
      }
    EOF
  }
}

### dynamodb integration response
resource "aws_api_gateway_integration_response" "dynamodb" {
  rest_api_id = aws_api_gateway_rest_api.dynamodb.id
  resource_id = aws_api_gateway_resource.dynamodb.id
  http_method = aws_api_gateway_method.dynamodb.http_method
  status_code = aws_api_gateway_method_response.dynamodb.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET'"
  }
  response_templates = {
    "application/json" = <<-EOF
      #set($inputRoot = $input.path('$'))
      {"Items":[#foreach($elem in $inputRoot.Items){"StreamId":"$elem.StreamId.N","Time":"$elem.Time.N","Category":"$elem.Category.S"}#if($foreach.hasNext),#end#end]}
    EOF
  }
  depends_on = [
    aws_api_gateway_integration.dynamodb
  ]
}

## method settings
resource "aws_api_gateway_method_settings" "dynamodb" {
  rest_api_id = aws_api_gateway_rest_api.dynamodb.id
  stage_name  = aws_api_gateway_deployment.dynamodb.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    throttling_rate_limit  = 100
    throttling_burst_limit = 100
  }
}

## deployment
resource "aws_api_gateway_deployment" "dynamodb" {
  stage_name  = "rcv"
  rest_api_id = aws_api_gateway_rest_api.dynamodb.id
  variables = {
    "deployedAt" = timestamp()
  }
  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_api_gateway_resource.dynamodb),
      jsonencode(aws_api_gateway_method.dynamodb),
      jsonencode(aws_api_gateway_method_response.dynamodb),
      jsonencode(aws_api_gateway_integration.dynamodb),
      jsonencode(aws_api_gateway_integration_response.dynamodb),
    ])))
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [variables]
  }
}
