import logging
from mqtt import MqttController
from key import *
from influx import Influx
from relay import RelayController
import json
import re


class Manager:
    ALARM = 0
    RELAY = 1
    TRIGGER = 2
    RELAY_STATE = 3
    ERROR = -1
    PATH_SENSORS = 'N/508cb1cb59e8/settings/0/Settings/RpiSensors/'
    PATH_RELAY = 'N/508cb1cb59e8/relays/0/Relay/'

    def __init__(self) -> None:
        self.mqtt = MqttController(broker=BROKER, on_message=self.on_message, clientName=CLIENT_NAME)
        self.influx = Influx(HOST, PORT)
        self.influx.connect_db(DATABASE_NAME)
        self.relays = RelayController()
        self.sensors = DEVICES # dict sensor -> alarm settings
        # TODO: suscribe to all mqtt topics needed
    

    def get_alarm(self, id) -> Alarm:
        return list(self.sensors.get.values())[id]
    def get_sensor(self, id):
        return list(self.sensors.keys())[id]
            
    def on_message(self, mqtt, userdate, message):
        ALARM = 0
        RELAY_STATE = 3

        res, id= self.pattern(message.topic)

        try:
            new_value = json.loads(message.payload)['value']
        except:
            return
        
        topic = message.topic[1:]
        
        if res == RELAY_STATE:

            logging.info(f'[MQTT] RELAY STATE CHANGED ---> RELAY {id} = {new_value}')
            self.relays.set_relay(id-1, new_value)
            return


        controller = self.get_sensor(id)
        alarm = self.get_alarm(id)  
        if not controller or not alarm:
            return
        if res == ALARM:
            if new_value:
                alarm.activate()
            else:
                alarm.deactivate()
                self.relays.update_mask('00000000')
                # TODO: if triggered I should turn off relays
        
        logging.info(f'[MQTT] -> RECEIVED ---> {topic} = {new_value}')

        alarm.settings.update({topic: new_value})
        
    def log(self, message):
        logging.debug(f'[SENSOR CRTL]  {message}')
    
    def read(self):
       
        relay_change = False
        for sensor, alarm in self.sensors.items():
           
            reading = sensor.read()

            if not reading:
                return
        
            self.influx.post_data(sensor.name, reading)


            if alarm.is_active:
                # TODO: check if alarm is triggered
                triggered = alarm.detect()
                
                if triggered:
                    relay_change = True
                    if alarm.state:
                        mask = alarm.settings.get_relay()
                        self.relays.update_mask(mask)
                    
                    else:
                        self.relays.update_mask('00000000')
                

        # we read all sensors, now we can apply the mask
        if relay_change:
            self.mqtt.publish_relays(self.relays.aux)
            self.relays.reset_maks()




    def pattern(self, text):
        if('settings' in text):
            sensor_id = int(text.replace(self.PATH_SENSORS, '')[0])
            
            if bool(re.compile (r'Settings/RpiSensors/\d/Alarm($| )').search(text)): return (self.ALARM, sensor_id)
            if bool(re.compile (r'Settings/RpiSensors/\d/AlarmSetting($| )').search(text)): return (self.RELAY, sensor_id)
            if bool(re.compile (r'Settings/RpiSensors/\d/AlarmTrigger($| )').search(text)): return (self.TRIGGER, sensor_id)
            return (self.ERROR)
        if 'relays' in text:
            relay_number = int(text.replace(self.PATH_RELAY, '')[0])
            if bool(re.compile (r'Relay/\d/State($| )').search(text)): return (self.RELAY_STATE, relay_number)
    
    def __str__(self):
        pass
