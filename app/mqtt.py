import paho.mqtt.client as paho
import json
import time
from register import *
import re

class MqttController(object):
    ALARM = 0
    RELAY = 1
    TRIGGER = 2
    ERROR = -1
    prefix = 'R/508cb1cb59e8/settings/0/Settings/RpiSensors/'



    def pattern(self, text):
        sensor_id = int(text.replace(self.prefix, '')[0])
        
        if bool(re.compile (r'Settings/RpiSensors/\d/Alarm($| )').search(text)): return (self.ALARM, sensor_id)
        if bool(re.compile (r'Settings/RpiSensors/\d/AlarmSetting($| )').search(text)): return (self.RELAY, sensor_id)
        if bool(re.compile (r'Settings/RpiSensors/\d/AlarmTrigger($| )').search(text)): return (self.TRIGGER, sensor_id)
        return (self.ERROR)

    def __init__(self, broker, port=1883, clientName="test") -> None:
        self.mqtt = paho.Client(clientName)  # create self.mqtt object
        self.mqtt.on_message = self.on_message
        self.mqtt.on_publish = self.on_publish
        self.mqtt.on_connect = self.on_connect
        self.mqtt.on_connect_fail = self.on_connect_fail
        self.mqtt.on_subscribe = self.on_suscribe
        self.mqtt.connect(broker, port, keepalive=60)
        self.mqtt.loop_start()

    def on_publish(self, mqtt, userdata, mid):
        print(f'[MQTT] -> PUBLISH')

    
        
    def on_message(self, mqtt, userdate, message):
        # print(
        #    f'[MQTT] -> RECEIVED ---> {message.topic} = {message.payload.decode("utf-8")}')
        

        res = self.pattern(message.topic)[0]
    
        if res == self.ALARM:
            print(f'[ALARM] {message.topic} | new value: {message.payload}')
            #CREATE ALARM
        elif res == self.RELAY:
            print(f'[RELAY] {message.topic} | new value: {message.payload}')
            #UPDATE RELAY SETTINGS FOR ALARM ID 
        elif res  == self.TRIGGER:
            #UPDATE TRIGGER SETTINGS FOR ALARM ID 
            print(f'[TRIGGER] {message.topic} | new value: {message.payload}')

        else:
            print(
        f'[MQTT] -> RECEIVED ---> {message.topic} = {message.payload}')

    def on_connect(self, client, userdata, flags, rc):
        print(
            f'[MQTT] -> SUCCESFULLY CONNECTED TO {client._client_id.decode("utf-8") }')

    def on_connect_fail(self, client, userdate):
        print(
            f'[MQTT] -> FAILED TO CONNECT ---> {client._client_id.decode("utf-8")}')

    def on_suscribe(self, mqtt, userdata, mid, quos):
        print(f'[MQTT] -> SUSCRIBED')

    def suscribeAll(self, obj: Settings):
        if not obj:
            raise EmptySettingsException(obj)
        for topic in obj.settings:
            self.mqtt.subscribe(f'R{topic}')




mqtt_controller = MqttController('192.168.1.101', 1883)
settings = SensorAlarmSettings(0) # Settings() 
mqtt_controller.suscribeAll(settings)

#mqtt_controller.mqtt.subscribe('R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm')

while True:
    mqtt_controller.mqtt.publish(
        'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', json.dumps({'value': 1}), qos=1)
    time.sleep(4)
    mqtt_controller.mqtt.publish(
        'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', json.dumps({'value': 0}), qos=1)

