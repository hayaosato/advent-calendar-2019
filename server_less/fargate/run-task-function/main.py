"""
task run
"""
import os
import boto3


def main(event, _):
    """
    hoge
    """
    filename = event['Records'][0]['s3']['bucket']['name']
    client = boto3.client('ecs')
    response = client.run_task(
        cluster=os.environ['CLUSTER_NAME'],
        count=1,
        launchType='FARGATE',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': [
                    os.environ['SUBNET_ID']
                ],
                'securityGroups': [
                    os.environ['SECURITY_GROUP_ID']
                ],
                'assignPublicIp': 'ENABLED'
            }
        },
        overrides={
            'containerOverrides': [
                {
                    'name': 'hogehoge',
                    'command': [
                        'python',
                        'main.py',
                        'ほげ{}'.format(filename)
                    ]
                },
            ]
        },
        taskDefinition=os.environ['TASK_DEFINITION']
    )
    print(response)
