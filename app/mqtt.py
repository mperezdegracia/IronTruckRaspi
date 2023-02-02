import paho.mqtt.client as paho
import json
import time
from register import *
import re
import json
from dummy import *
'''

class MqttController(object):
    ALARM = 0
    RELAY = 1
    TRIGGER = 2
    ERROR = -1
    prefix = 'N/508cb1cb59e8/settings/0/Settings/RpiSensors/'



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

        res, sensor_id= self.pattern(message.topic)
        global network

        new_value = json.loads(message.payload)['value']
        topic = message.topic[1:]


        controller = network.get(21)
        if not controller:
            #sensor not available 
            return 
        if res == self.ALARM:
            pass
            controller.alarm.activate() if new_value else controller.alarm.deactivate()
        
        
        print(
        f'[MQTT] -> RECEIVED ---> {topic} = {new_value}')

        controller.settings.update({topic: new_value})

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
            print(f'SUBSCRIBING TO N{topic}')
            self.mqtt.publish(f'R{topic}')
            self.mqtt.subscribe(f'N{topic}')

    def keep_alive(self):
        self.mqtt.publish("R/508cb1cb59e8/keepalive")



if __name__ == '__main__':

    mqtt_controller = MqttController('192.168.1.101', 1883)
    settings = SensorAlarmSettings(0) # Settings() 
    mqtt_controller.suscribeAll(settings)

    #mqtt_controller.mqtt.subscribe('R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm')

    while True:
        #
        # #mqtt_controller.mqtt.publish(
        #    'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', json.dumps({'value': 1}), qos=1)
        mqtt_controller.keep_alive()
        time.sleep(30)
       #mqtt_controller.mqtt.publish(
          #  'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', json.dumps({'value': 0}), qos=1)



'''