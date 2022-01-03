import os
import json


def lambda_handler(event, context):
    print(event)
    if event['taskType'] != 'MyTask':
        raise Exception('Task Type not defined!')
    else:
        return {
            "statusCode": 200
        }
