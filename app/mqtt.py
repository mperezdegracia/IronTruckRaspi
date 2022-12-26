import paho.mqtt.client as paho
import json
import time
from register import *


class MqttController(object):

    def __init__(self, broker, port) -> None:
        self.mqtt = paho.Client("IronTruck")  # create self.mqtt object
        self.mqtt.on_message = self.on_message
        self.mqtt.on_publish = self.on_publish
        self.mqtt.on_connect = self.on_connect
        self.mqtt.on_connect_fail = self.on_connect_fail
        self.mqtt.on_subscribe = self.on_suscribe
        self.mqtt.connect(broker, port, keepalive=60)
        self.mqtt.loop_start()

    def on_publish(self, mqtt, userdata, mid):
        print(f'[MQTT] -> PUBLISH ---> {userdata}')

    def on_message(self, mqtt, userdate, message):
        print(
            f'[MQTT] -> RECEIVED ---> {message.topic} = {message.payload.decode("utf-8")}')

    def on_connect(self, client, userdata, flags, rc):
        print(
            f'[MQTT] -> SUCCESFULLY CONNECTED TO {client._client_id.decode("utf-8") }')

    def on_connect_fail(self, client, userdate):
        print(
            f'[MQTT] -> FAILED TO CONNECT ---> {client._client_id.decode("utf-8")}')

    def on_suscribe(self, mqtt, userdata, mid, quos):
        print(f'[MQTT] -> SUSCRIBED ---> {mid}')

    def suscribeAll(self, obj: Settings):
        if not obj:
            raise EmptySettingsException(obj)
        for topic in obj.settings:
            self.mqtt.subscribe(f'R{topic}')


'''

mqtt_controller = MqttController('192.168.1.100', 1883)
settings = Settings()  # AlarmSettings(0)
mqtt_controller.suscribeAll(settings)

# mqtt_controller.mqtt.subscribe('R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm')

while True:
    mqtt_controller.mqtt.publish(
        'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', json.dumps({'value': 1}))
    time.sleep(4)
    mqtt_controller.mqtt.publish(
        'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', json.dumps({'value': 0}))

'''
