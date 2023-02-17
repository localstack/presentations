# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

CLIENT_ID_KEY = "ClientID"
CONNECT_NUM_KEY = "ConnectVersionNum"
CONNECT_TIME_KEY = "ConnectTime"
DISCONNECT_NUM_KEY = "DisconnectVersionNum"
DISCONNECT_TIME_KEY = "DisconnectTime"
STATUS_KEY = "Status"


class ConnectRecord:
    """ A data class for managing DynamoDB records """
    def __init__(self, client_id):
        self.client_id: str = client_id
        self.connect_number: int = -1
        self.disconnect_number: int = -1
        self.connect_time: int = 0
        self.disconnect_time: int = 0
        self.connect_event_received: bool = False
        self.disconnect_event_received: bool = False
        self.status: str = ""

    @classmethod
    def from_record(cls, client_id, record):
        instance = cls(client_id)
        if "Item" not in record:
            return instance

        item = record["Item"]
        if CONNECT_NUM_KEY in item:
            instance.connect_event_received = True
            instance.connect_number = item[CONNECT_NUM_KEY]
            instance.connect_time = item[CONNECT_TIME_KEY]
        if DISCONNECT_NUM_KEY in item:
            instance.disconnect_event_received = True
            instance.disconnect_number = item[DISCONNECT_NUM_KEY]
            instance.disconnect_time = item[DISCONNECT_TIME_KEY]
        return instance

    def create_item(self):
        item = {CLIENT_ID_KEY: self.client_id}
        if self.connect_event_received:
            item[CONNECT_NUM_KEY] = self.connect_number
            item[CONNECT_TIME_KEY] = self.connect_time
        if self.disconnect_event_received:
            item[DISCONNECT_NUM_KEY] = self.disconnect_number
            item[DISCONNECT_TIME_KEY] = self.disconnect_time
        if self.status:
            item[STATUS_KEY] = self.status
        return item

    def set_connect_event(self, version_number, timestamp):
        self.connect_event_received = True
        self.connect_number = version_number
        self.connect_time = timestamp

    def set_disconnect_event(self, version_number, timestamp):
        self.disconnect_event_received = True
        self.disconnect_number = version_number
        self.disconnect_time = timestamp
