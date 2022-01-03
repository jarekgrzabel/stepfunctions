import os
import json


def lambda_handler(event, context):
    print(event["taskToken"])
