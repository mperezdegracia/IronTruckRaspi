from influx import *
from sensor import *
from temp import *
from gas import *
from relay import *
from alarm import *
from settings import *
from threading import Thread
import paho.mqtt.client as paho
import json
import time
from settings import *
import re
import json
from datetime import date

#**********************  CONTROLLERS *******************************
class MqttController(object):
    ALARM = 0
    RELAY = 1
    TRIGGER = 2
    RELAY_STATE = 3
    ERROR = -1
    PATH_SENSORS = 'N/508cb1cb59e8/settings/0/Settings/RpiSensors/'
    PATH_RELAY = 'N/508cb1cb59e8/relays/0/Relay/'

    def pattern(self, text):
        if('settings' in text):
            sensor_id = int(text.replace(self.PATH_SENSORS, '')[0])
            
            if bool(re.compile (r'Settings/RpiSensors/\d/Alarm($| )').search(text)): return (self.ALARM, sensor_id)
            if bool(re.compile (r'Settings/RpiSensors/\d/AlarmSetting($| )').search(text)): return (self.RELAY, sensor_id)
            if bool(re.compile (r'Settings/RpiSensors/\d/AlarmTrigger($| )').search(text)): return (self.TRIGGER, sensor_id)
            return (self.ERROR)
        if 'relays' in text:
            relay_number = int(text.replace(self.PATH_RELAY, '')[0])
            print(f'TEXT {text} RELAY NUMBER {relay_number}')
            if bool(re.compile (r'Relay/\d/State($| )').search(text)): return (self.RELAY_STATE, relay_number)

    def __init__(self, broker, port=1883, clientName="test") -> None:
        self.mqtt = paho.Client(clientName)  # create self.mqtt object
        self.mqtt.on_message = self.on_message
        self.mqtt.on_publish = self.on_publish
        self.mqtt.on_connect = self.on_connect
        self.mqtt.on_connect_fail = self.on_connect_fail
        self.mqtt.on_subscribe = self.on_suscribe
        self.mqtt.connect(broker, port, keepalive=60)
        self.mqtt.loop_start()
        self.suscribeList([f'/508cb1cb59e8/relays/0/Relay/{i}/State' for i in range(8)])

    def on_publish(self, mqtt, userdata, mid):
        print(f'[MQTT] -> PUBLISH')

    def updateRelayStates(self, bitmask: RelayMask):
        for relay_number, bit in enumerate(bitmask, start=1):
            self.mqtt.publish(f'W/508cb1cb59e8/relays/0/Relay/{relay_number}/State', json.dumps({'value': bit}))
            print(f'[MQTT] PUBLISHING ---> RELAY {relay_number} : {bit}')

        

    
    
        
    def on_message(self, mqtt, userdate, message):

        res, id= self.pattern(message.topic)
        global network
        
        try:
            new_value = json.loads(message.payload)['value']
        except:
            print(f'parsing to JSON FAILED: {message.payload}')
            return

        topic = message.topic[1:]

        if res == self.RELAY_STATE:
            print(f'[MQTT] -> RELAY STATE CHANGED ---> RELAY {id} = {new_value}')
            RelayController.turnON(id-1) if new_value else RelayController.turnOFF(id-1)
            return
            
        controller = network.get(id)        
        if res == self.ALARM:
            
            if not controller:
            #sensor not available 
                  return 
            controller.alarm.activate() if new_value else controller.alarm.deactivate()
     
        print(f'[MQTT] -> RECEIVED ---> {topic} = {new_value}')

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
    def suscribeList(self, list):
        if list:
            for topic in list:
                print(f'SUBSCRIBING TO N{topic}')
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
        self.victron.suscribeAll(settings)
        self.relay_mask : RelayMask = None

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

            #state changed 
            # write something to database TODO

            state = self.alarm.get_state()
            settings = self.alarm.settings.getRelay()
            if(self.relay_mask):
                if(state):
                    self.relay_mask.apply_to_mask(settings)  
            else:
                # this would execute if the controller is not contained in network
                # only use if this sensor is working alone
                print("*************************THIS SHOULD NOT BE EXECUTED***********************")
                if triggered:
                    if state:
                        RelayController.apply_setting(settings)    
                    else:
                        RelayController.allOFF()
    def send_data(self):
        data = {
            'measurement': self.sensor.name,
            'time': datetime.datetime.now(),
            'fields': {
            },
        }
        fields = data['fields']
        reading = self.sensor._read()

        if reading is None:
            if(self.relay_mask and self.alarm.get_state() and self.has_alarm()):
                print("READING IS NONE, APPLYING MASK ANYWAY")
                self.relay_mask.apply_to_mask(self.alarm.settings.getRelay())  
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
    
    def add(self,new_controller):
        for controller in self.controllers:
            if(controller.sensor == new_controller.sensor):
                print(f'[MAIN][FAILED] trying to add a controller that already exists! {new_controller}')
                return False
            if(controller.settings.id == new_controller.settings.id):
                print(f'[MAIN][FAILED] same setting ID for different controllers! {new_controller}')
                return False

        self.controllers.append(new_controller.set_mask(self.relay_mask))
        return True


    def get(self, setting_id):
        for i, controller in enumerate(self.controllers):
            if(controller.settings.id == setting_id):
                return self.controllers[i]
        print(f'[MAIN][FAILED] trying to get controller -> Sensor Pin: {setting_id}')
        return False

    def __iter__(self):
        return self.controllers.__iter__()

    def __str__(self):
        string = "["
        for controller in self:
            string += f'{str(controller)}, '
        string = f'{string[:-2] }]'
        return f'[MAIN] CONTROLLER SET:  HEAD --->  {string}'

    def sensors_read(self):
        for controller in self:
            controller.send_data()
        if RelayController.apply_mask(self.relay_mask):
            mqtt.updateRelayStates(self.relay_mask)

        self.relay_mask.reset()


#*********************************


#            --------
#***********|  MAIN  |************
#            --------



# *********** INFLUX *************


HOST = "influxdb"  # Docker InfluxDB container running address
PORT = 8086
DATABASE_NAME = "IronTruck"
influx = Influx(HOST, PORT)
influx.connect_db(DATABASE_NAME)

# ********************************

# *********** MQTT ***************

BROKER = "192.168.1.104"  # IP Victron CCGX PORT: 1883 (default)
CLIENT_NAME = "IronTruck"
mqtt = MqttController(broker=BROKER, clientName=CLIENT_NAME)
KEEP_ALIVE = 30
# ********************************
READING_FREC = 5

# We now have running MQTT and InfluxDB database connection



network = SensorControllerSet()
timer = datetime.datetime.now()

def setup():
    network.add(SensorController(DHT_22(pin=21, name="Habitacion de Mateo"),SensorAlarmSettings(id=0), influx, mqtt))
    network.add(SensorController(MQ2(pin=0, name="GAS Cocina"),SensorAlarmSettings(id=1), influx, mqtt))

def keep_alive_count ():
    global timer
    passed = datetime.datetime.now() - timer
    if passed.total_seconds() >= KEEP_ALIVE:
        mqtt.keep_alive()
        timer = datetime.datetime.now() 


def main():
    setup()
    while True:
        
        network.sensors_read()
        keep_alive_count()
        time.sleep(READING_FREC)
        
        
main()
