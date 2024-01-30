# Copyright 2023 Alexander Rose
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##
# Meta
##

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

##
# Modules
##

module "network" {
  source = "./modules/network"
}

module "lambda" {
  source = "./modules/lambda"
}

module "s3" {
  source = "./modules/s3"
}

module "kvs" {
  source = "./modules/kvs"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "ssm" {
  source = "./modules/ssm"
}

module "integration" {
  source = "./modules/integration"

  subnet_id = module.network.subnet_id
  dynamodb_arn = module.dynamodb.arn
  dynamodb_name = module.dynamodb.name
  kvs_arn = module.kvs.arn
  kvs_name = module.kvs.name
  lambda_arn = module.lambda.arn
  lambda_function_name = module.lambda.function_name
  s3_arn = module.s3.arn
  s3_bucket = module.s3.bucket
  ssm_name = module.ssm.name
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "dynamodb_table" {
  value = module.dynamodb.name
}

output "s3_bucket" {
  value = module.s3.bucket
}

output "kvs_stream" {
  value = module.kvs.name
}

output "ssm_parameter" {
  value = module.ssm.name
}
