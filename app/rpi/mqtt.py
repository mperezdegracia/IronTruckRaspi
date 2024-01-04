import logging
import re
import json
import paho.mqtt.client as paho
from settings import EmptySettingsException, Settings
from relay import RelayMask

class MqttController(object):

    def log(self, message):
        logging.debug(f'[MQTT]  {message}')

    def __init__(self, broker, on_message, port=1883, clientName="test") -> None:
        self.mqtt = paho.Client(clientName)  # create self.mqtt object
        self.mqtt.on_message = on_message
        self.mqtt.on_publish = self.on_publish
        self.mqtt.on_connect = self.on_connect
        self.mqtt.on_connect_fail = self.on_connect_fail
        self.mqtt.on_subscribe = self.on_subscribe
        self.mqtt.connect(broker, port, keepalive=60)
        self.mqtt.loop_start()
        #self.subscribe_all([f'/508cb1cb59e8/relays/0/Relay/{i}/State' for i in range(1,9)])

    def on_publish(self, mqtt, userdata, mid):
        self.log('PUBLISH')

    def on_connect(self, client, userdata, flags, rc):
        self.log(
            f' SUCCESFULLY CONNECTED TO {client._client_id.decode("utf-8") }')

    def on_connect_fail(self, client, userdate):
        self.log(
            f' FAILED TO CONNECT ---> {client._client_id.decode("utf-8")}')

    def on_subscribe(self, mqtt, userdata, mid, quos):
        self.log(f' SUSCRIBED')
    
    def subscribe_settings(self, obj: Settings):
        if not obj: 
            raise EmptySettingsException(obj)
        for topic in obj.settings:
            self.log(f'SUBSCRIBING TO N{topic}')
            self.mqtt.publish(f'R{topic}')
            self.mqtt.subscribe(f'N{topic}')

    def subscribe_all(self, list):
        if list:
            for topic in list:
                self.log(f'SUBSCRIBING TO N{topic}')
                self.mqtt.publish(f'R{topic}')
                self.mqtt.subscribe(f'N{topic}')

    def publish_relays(self, bitmask):
        for relay_number, bit in enumerate(bitmask, start=1):
            if bit != 'x':
                self.mqtt.publish(f'W/508cb1cb59e8/relays/0/Relay/{relay_number}/State', json.dumps({'value': bit}))
    def keep_alive(self):
        self.mqtt.publish("R/508cb1cb59e8/keepalive")



