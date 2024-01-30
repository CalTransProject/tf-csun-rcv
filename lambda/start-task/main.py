import os
import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    response = {
        'statusCode': 200,
        "headers": {
            "Content-Type": "application/json"
        },
        'body': "{}"
    }

    try:
        logger.debug("event: %s", event)

        logger.debug("context: %s", context)

        logger.debug("environment: %s", os.environ)

        ecs_parameters = dict(
            cluster=os.getenv('CLUSTER_ARN'),
            count=1,
            launchType='FARGATE',
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': [
                        os.getenv("SUBNET_ID")
                    ],
                    'assignPublicIp': 'ENABLED'
                }
            },
            taskDefinition=os.getenv("TASK_DEFINITION_ARN")
        )

        logger.debug("parameters: %s", ecs_parameters)

        logger.info("Attempting to start ECS Task")

        ecs = boto3.client('ecs')

        run_task_response = ecs.run_task(**ecs_parameters)

        logger.debug(run_task_response)

        if len(run_task_response['failures']) > 0:
            raise Exception(run_task_response['failures'][0]['reason'])

        logger.info("Successfully started container")

    except Exception as e:
        logger.warn("error: %s", e)
        response = {'statusCode': 500}
    finally:
        logger.info("response: %s", response)
        return response