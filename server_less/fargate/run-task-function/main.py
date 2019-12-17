"""
task run
"""
import os
import boto3


def main():
    """
    hoge
    """
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
                    'name': 'hoge',
                    'command': [
                        'python',
                        'main.py',
                        'ほげ'
                    ]
                },
            ]
        },
        taskDefinition='python-sample:2'
    )
    print(response)
