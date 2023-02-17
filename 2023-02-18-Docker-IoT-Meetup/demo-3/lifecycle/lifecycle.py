#  Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#  SPDX-License-Identifier: MIT-0
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy of this
#  software and associated documentation files (the "Software"), to deal in the Software
#  without restriction, including without limitation the rights to use, copy, modify,
#  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

from .connect_record import ConnectRecord

VERSION_RESET_DURATION_MS = 3600 * 1000


def update(event, table):
    """ The main logic for checking device connectivity and updating DynamoDB """
    client_id = event["clientId"]
    version_number = event["versionNumber"]
    timestamp = event["timestamp"]

    # Ignore test client
    if client_id.startswith("iotconsole"):
        return

    # Load from DynamoDB
    try:
        response = table.get_item(Key={"ClientID": client_id})
    except KeyError:
        response = {}
    record = ConnectRecord.from_record(client_id, response)

    is_connected_event = event["eventType"] == "connected"

    # If a client is not connected for approximately one hour, the version number is reset to 0.
    # https://docs.aws.amazon.com/iot/latest/developerguide/life-cycle-events.html
    version_reset = False
    if record.disconnect_event_received:
        version_reset = version_number == 0 and event["timestamp"] - record.disconnect_time >= VERSION_RESET_DURATION_MS

    # Lifecycle messages might be sent out of order.
    # Overwrite only when the received event is newer.
    if is_connected_event:
        if version_reset or version_number > record.connect_number or not record.connect_event_received:
            record.set_connect_event(version_number, timestamp)
    else:
        if version_reset or version_number > record.disconnect_number or not record.disconnect_event_received:
            record.set_disconnect_event(version_number, timestamp)

    # The first message is a disconnect event
    if not record.connect_event_received:
        record.status = "Disconnected"
    # Only a connect event has been sent for the session
    elif record.connect_number > record.disconnect_number or not record.disconnect_event_received:
        record.status = "Connected"
    # Reconnect after more than an hour
    elif version_reset and is_connected_event and record.disconnect_number > 0:
        record.status = "Connected"
    else:
        record.status = "Disconnected"

    # Update DynamoDB
    item = record.create_item()
    table.put_item(Item=item)
