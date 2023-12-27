from datetime import datetime
import threading
import time
import re
import json
import paho.mqtt.client as paho
import custom_logger
import logging

from influx import Influx
from key import  KEEP_ALIVE, READING_FREC, HOST, PORT, DATABASE_NAME, BROKER, CLIENT_NAME  # Assuming this is a constant in key.py
from sensor import Sensor
from temp import DHT_22  # Assuming Temp is the module for temperature-related functions
from gas import MQ2  # Assuming Gas is the module for gas-related functions
from relay import RelayController, RelayMask
from alarm import Alarm, SensorAlarmSettings
from settings import EmptySettingsException, Settings
#**********************  CONTROLLERS *******************************
class MqttController(object):
    ALARM = 0
    RELAY = 1
    TRIGGER = 2
    RELAY_STATE = 3
    ERROR = -1
    PATH_SENSORS = 'N/508cb1cb59e8/settings/0/Settings/RpiSensors/'
    PATH_RELAY = 'N/508cb1cb59e8/relays/0/Relay/'


    def log(self, message):
        logging.debug(f'[MQTT]  {message}')

    
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

    def __init__(self, broker, port=1883, clientName="test") -> None:
        self.mqtt = paho.Client(clientName)  # create self.mqtt object
        self.mqtt.on_message = self.on_message
        self.mqtt.on_publish = self.on_publish
        self.mqtt.on_connect = self.on_connect
        self.mqtt.on_connect_fail = self.on_connect_fail
        self.mqtt.on_subscribe = self.on_subscribe
        self.current_relay_state = None
        self.mqtt.connect(broker, port, keepalive=60)
        self.mqtt.loop_start()
        self.subscribe_all([f'/508cb1cb59e8/relays/0/Relay/{i}/State' for i in range(1,9)])

    def on_publish(self, mqtt, userdata, mid):
        self.log('PUBLISH')

    def update_relay_states(self, bitmask: RelayMask):
        for relay_number, bit in enumerate(bitmask, start=1):
            if bit != 'x':
                self.mqtt.publish(f'W/508cb1cb59e8/relays/0/Relay/{relay_number}/State', json.dumps({'value': bit}))

        if  bitmask != self.current_relay_state or self.current_relay_state is None:
            self.current_relay_state = bitmask
            self.log(f'RELAY STATE CHANGED ---> {bitmask}')
    def on_message(self, mqtt, userdate, message):

        res, id= self.pattern(message.topic)
        global network
        
        try:
            new_value = json.loads(message.payload)['value']
        except:
            return

        topic = message.topic[1:]

        if res == self.RELAY_STATE:
            logging.info(f'[MQTT] RELAY STATE CHANGED ---> RELAY {id} = {new_value}')
            relays.get(id-1).set_state(new_value)
            return
            
        controller = network.get(id)        
        if res == self.ALARM and controller:
            
            if not controller:
            #sensor not available 
                return 
            if new_value:   
                controller.alarm.activate()  
            else:
                controller.alarm.deactivate()
                network.relay_mask.apply_to_mask(controller.alarm.settings.get_relay(), inverse = True)


     
        self.log(f'[MQTT] -> RECEIVED ---> {topic} = {new_value}')

        controller.settings.update({topic: new_value})

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


    def keep_alive(self):
        self.mqtt.publish("R/508cb1cb59e8/keepalive")





class SensorController(object):
    def __init__(self, sensor: Sensor, settings: SensorAlarmSettings ,database: Influx, victron: MqttController) -> None:
        self.sensor = sensor
        self.settings = settings
        self.database = database
        self.victron = victron
        self.alarm = Alarm(self.sensor, self.settings)   
        self.victron.subscribe_settings(settings)
        self.relay_mask : RelayMask = None
    def log(self, message):
        logging.debug(f'[SENSOR CTRL]  {message}')

    def has_alarm(self):
        return self.alarm.is_active

    def create_alarm(self, inverse=False):
        self.alarm = Alarm(self.sensor, self.settings, inverse)

    def set_mask(self, mask: RelayMask):
        self.relay_mask = mask
        return self


    def alarm_handling(self):
        if self.has_alarm():

            triggered = self.alarm.detect()
            state = self.alarm.get_state()
            settings = self.alarm.settings.get_relay()
            if(self.relay_mask):
                if(state): 
                    self.relay_mask.apply_to_mask(settings)  
                else:
                    if triggered:
                        self.relay_mask.apply_to_mask(settings, inverse = True)  
    
    def send_data(self):
        data = {
            'measurement': self.sensor.name,
            'time': datetime.now(),
            'fields': {
            },
        }
        fields = data['fields']
        reading = self.sensor._read()

        if reading is None:
            if(self.relay_mask and self.alarm.get_state() and self.has_alarm()):
                self.log("READING IS NONE, APPLYING MASK ANYWAY")
                self.relay_mask.apply_to_mask(self.alarm.settings.get_relay())  
            return  # failed reading
            

        for measurement, value in reading.items():
            fields[measurement] = value

        self.database.client.write_points([data])
        self.alarm_handling()
     
        return


    def __str__(self) -> str:
        return f'Sensor: {self.sensor}, Alarm: {self.alarm}'




class SensorControllerSet:
    
    def __init__(self) -> None:
        self.controllers = []
        self.relay_mask = RelayMask()
    def log(self, message):
        logging.debug(f'[SENSOR CRTL]  {message}')

    def add(self,new_controller):
        for controller in self.controllers:
            if(controller.sensor == new_controller.sensor):
                self.log(f'trying to add a controller that already exists! {new_controller}')
                return False
            if(controller.settings.id == new_controller.settings.id):
                self.log(f'same setting ID for different controllers! {new_controller}')
                return False

        self.controllers.append(new_controller.set_mask(self.relay_mask))
        return True


    def get(self, setting_id):
        for i, controller in enumerate(self.controllers):
            if(controller.settings.id == setting_id):
                return self.controllers[i]
        self.log(f'trying to get controller -> Sensor Pin: {setting_id}')
        return False

    def __iter__(self):
        return self.controllers.__iter__()

    def __str__(self):
        string = "["
        for controller in self:
            string += f'{str(controller)}, '
        string = f'{string[:-2] }]'
        return f'CONTROLLER SET:  HEAD --->  {string}'

    def sensors_read(self):
        for controller in self:
            controller.send_data()
        
        #logging.info(f'APPLYING MASK {self.relay_mask}')
        mqtt.update_relay_states(self.relay_mask)
        self.relay_mask.reset()


#*********************************


#            --------
#***********|  MAIN  |************
#            --------


# *********** INFLUX *************
influx = Influx(HOST, PORT)
influx.connect_db(DATABASE_NAME)
# ********************************

# *********** MQTT ***************

mqtt = MqttController(broker=BROKER, clientName=CLIENT_NAME)
# ********************************
# We now have running MQTT and InfluxDB database connection


# def keep_alive_count ():
#     global timer
#     passed = datetime.now() - timer
#     if passed.total_seconds() >= KEEP_ALIVE:
#         mqtt.keep_alive()
#         timer = datetime.now() 



network = SensorControllerSet()
relays = RelayController()

time.sleep(20)

class NamedTimer(threading.Timer):
    def __init__(self, interval, function, name, args=None, kwargs=None):
        super().__init__(interval, function, args, kwargs)
        self.name =  name

def setup():
    network.add(SensorController(DHT_22(pin=21, name="Habitacion de Mateo"),SensorAlarmSettings(id=0), influx, mqtt))
    network.add(SensorController(MQ2(pin=0, name="GAS Cocina"),SensorAlarmSettings(id=1), influx, mqtt))
    

def run_thread():
    NamedTimer(5.0, run_thread, name="Sensors").start()  # Run the function every 5 seconds
    network.sensors_read()

def keep_alive_thread():
    NamedTimer(KEEP_ALIVE, keep_alive_thread, name= "Keep Alive").start()  # Run the function every 5 seconds
    mqtt.keep_alive()

def main():
    setup()
    keep_alive_thread()
    run_thread()

   
        
        

if __name__ == "__main__":
    main()