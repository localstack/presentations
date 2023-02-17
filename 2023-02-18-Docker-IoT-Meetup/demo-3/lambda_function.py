# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import boto3

from lifecycle.lifecycle import update

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("DeviceConnectivity")


def lambda_handler(event, context):
    """ Wrapper function of the main logic """
    update(event, table)
