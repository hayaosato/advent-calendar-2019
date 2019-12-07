"""
Lambda function
"""
import os
from slacker import Slacker


def slack_notification(
        message, channel='#general', user='Lambda Function', emoji=':lambda:'):
    """
    slack通知する関数
    Parameters
        ----------
        message : string
            Slackに送信するメッセージ
        channel(optional) : string
            メッセージを送信する先のチャンネル名
        Returns
        -------
        Raises
        ------
    """
    slack_api_key = os.environ['SLACK_API_KEY']
    if slack_api_key != "":
        slack = Slacker(slack_api_key)
        slack.chat.post_message(
            channel,
            message,
            username=user,
            icon_emoji=emoji
        )


def main(event, _):
    """
    Lambda handler
    """
    slack_notification(event)
