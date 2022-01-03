import os
import json
import boto3

client = boto3.client('stepfunctions')


def lambda_handler(event, context):
    if not event["taskToken"]:
        raise Exception('`taskToken` not found!')
    if not event["taskType"]:
        raise Exception('`taskType` not found!')

    token = event["taskToken"]
    output = '{ "taskType": "' + event["taskType"] + '" }'
    response = client.send_task_success(
        taskToken=token,
        output=output
    )
    return response
