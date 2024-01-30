# CSUN-RCV Terraform Setup

This repository contains Terraform code to set up AWS resources supporting the California State University Northridge Real-time Computer Vision system.

*see also*: 
- [csun-rcv](https://github.com/rosealexander/csun-rcv)
- [csun-rcv-ui-demo](https://github.com/rosealexander/csun-rcv-ui-demo)

## Prerequisites

Terraform v1.6.

## Container Images

The following container images must be uploaded to Amazon ECR. 
Build scripts are available in the linked repositories:

- [ocv-dnn-detector-lambda](https://github.com/rosealexander/docker-ocv-dnn-detector-lambda)
- [csun-rcv](https://github.com/rosealexander/docker-csun-rcv)

## Commands

1. Run `terraform plan -out tfplan` to generate an execution plan.
2. Run `terraform apply tfplan` to apply the generated plan and create the resources.

These commands should be executed from the project's root directory.

## Modules

The Terraform setup includes the following modules, each corresponding to a specific service:

- `dynamoDB`: DynamoDB table setup.
- `integration`: Fargate task for CSUN-RCV image. Launches the task when the Kinesis Video Stream becomes active and automatically shuts down when the stream ends.
- `kvs`: Kinesis Video Stream setup.
- `lambda`: Object detector Lambda setup.
- `network`: Network configuration.
- `s3`: S3 bucket setup.
- `ssm`: Systems Manager setup.

## API Endpoint

The API URL for the CSUN-RCV UI demo can be found through the AWS Management Console in the API Gateway section.

## Outputs

After Terraform applies the configuration, you can find the following outputs:

- `lambda_function_name`: Name of the AWS Lambda function for object detection.
- `dynamodb_table`: Name of the DynamoDB table.
- `s3_bucket`: Name of the S3 bucket for storing processed frames.
- `kvs_stream`: Name of the Kinesis Video Stream.
- `ssm_parameter`: Path to the AWS Systems Manager parameter containing system metadata.

## Tear Down

To tear down all resources created by Terraform, follow these steps:

1. Run `terraform destroy` from the project's root directory.
2. Confirm by typing `yes` when prompted.

## Cost Considerations

### Lambda (Object Detector)
- 1024 MB memory configuration.
- [Lambda Pricing](https://aws.amazon.com/lambda/pricing/)

### Fargate (Integration Module)
- CPU: 1024, Memory: 2048 MB configuration.
- [Fargate Pricing](https://aws.amazon.com/fargate/pricing/)

### Kinesis Video Stream
- Incur charges based on usage.
- [KVS pricing](https://aws.amazon.com/kinesis/video-streams/pricing/)

### S3
- Fragments saved to S3 are discarded after 24 hours.
- May incur charges based on storage and request usage.
- [S3 pricing](https://aws.amazon.com/s3/pricing/)

### Cost Structure
- The system incurs no charges if not running.
- When running, Lambda first falls within the free tier before incurring charges.
- Kinesis Video Stream and S3 may incur charges based on usage.
- ECS Fargate incurs charges only when the task is running.

Monitor usage and costs regularly to optimize spending and ensure cost efficiency.

## License

This project is licensed under the Apache License 2.0. See the LICENSE file for details.
