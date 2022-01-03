module "step_function" {
  source                                 = "terraform-aws-modules/step-functions/aws"
  cloudwatch_log_group_name              = "jarekg-sfn-log"
  cloudwatch_log_group_retention_in_days = 1
  logging_configuration = {
    include_execution_data = true
    level                  = "ALL"
  }
  name       = "jarekg-step-function"
  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "Start",
  "States": {
    "Start": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "Payload": {
          "taskType.$": "$.taskType"
        },
        "FunctionName": "${module.start.lambda_function_arn}"
      },
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "ErrorProcessor",
          "ResultPath": "$.error"
        }
      ],
      "Next": "Success"
    },
    "ErrorProcessor": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
      "Parameters": {
        "Payload": {
            "taskToken.$": "$$.Task.Token"
        },
        "FunctionName": "${module.error.lambda_function_arn}"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "Start"
    },
    "Success": {
      "Type": "Succeed"
    }
  }
}
EOF

  service_integrations = {
    lambda = {
      lambda = [module.start.lambda_function_arn, module.error.lambda_function_arn]
    }
  }
  type = "STANDARD"
  tags = {
    Owner = "Jarek Grzabel"
  }
}

module "start" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "jarekg-start"
  description   = "My start lambda function"
  handler       = "start.lambda_handler"
  runtime       = "python3.8"

  source_path = "lambdas/start"

  tags = {
    Name  = "jarekg-start",
    Owner = "Jarek Grzabel"
  }
}

module "error" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "jarekg-error"
  description   = "My error lambda function"
  handler       = "start.lambda_handler"
  runtime       = "python3.8"

  source_path = "lambdas/error"

  tags = {
    Name  = "jarekg-error",
    Owner = "Jarek Grzabel"
  }
}

module "state_machine" {
  source             = "terraform-aws-modules/lambda/aws"
  attach_policy_json = true
  policy_json        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "states:*"
      ],
      "Effect": "Allow",
      "Resource": "${module.step_function.state_machine_arn}"
    }
  ]
}
EOF
  function_name      = "jarekg-state-machine"
  description        = "My State Machine Lambda function"
  handler            = "start.lambda_handler"
  runtime            = "python3.8"

  source_path = "lambdas/statemachine"

  tags = {
    Name  = "jarekg-start",
    Owner = "Jarek Grzabel"
  }
}
