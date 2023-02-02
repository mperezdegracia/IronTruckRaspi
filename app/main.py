from mqtt import *
from influx import *
from sensor import *
from temp import *
from gas import *
from relay import *
from alarm import *
from register import *
from threading import Thread

#**********************  CONTROLLERS *******************************
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





class SensorController(object):
    def __init__(self, sensor: Sensor, settings: SensorAlarmSettings ,database: Influx, victron: MqttController) -> None:
        self.sensor = sensor
        self.settings = settings
        self.database = database
        self.victron = victron
        self.alarm = Alarm(self.sensor, self.settings)

    def has_alarm(self):
        return self.alarm.is_active

    def create_alarm(self, inverse=False):
        self.alarm = Alarm(self.sensor, self.settings, inverse)


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
            return  # failed reading
        for measurement, value in reading.items():
            fields[measurement] = value

        self.database.client.write_points([data])

        if self.has_alarm() and self.alarm.detect() :
            # write something to database TODO
            for index, value in enumerate(self.alarm.settings.getRelay()):
                if(value == '1'):
                    RelayController.turnON(index)

        return



    def __str__(self) -> str:
        return f'Sensor: {self.sensor}, Alarm: {self.alarm}'



class SensorControllerSet:

    def __init__(self) -> None:
        self.controllers = []

    def add(self,new_controller):
        for controller in self.controllers:
            if(controller.sensor.pin == new_controller.sensor.pin):
                print(f'[FAILED] trying to add new controller {new_controller}')
                return False

        self.controllers.append(new_controller)
        return True
    def get(self, id):
        for i, controller in enumerate(self.controllers):
            if(controller.sensor.pin == id):
                return self.controllers[i]
        print(f'[FAILED] trying to get controller -> Sensor Pin: {id}')
        return False

    def __iter__(self):
        return self.controllers.__iter__()

    def __str__(self):
        string = "["
        for controller in self:
            string += str(controller)
            string += ' ' 
        return f'CONTROLLER SET:  HEAD --->  {string}]'


#***********************************************************


#            --------
#***********|  MAIN  |**************
#            --------
#time.sleep(60)
# *********** INFLUX *************


HOST = "influxdb"  # Docker InfluxDB container running address
PORT = 8086
DATABASE_NAME = "IronTruck"
influx = Influx(HOST, PORT)
influx.connect_db(DATABASE_NAME)

# ********************************

# *********** MQTT ***************

BROKER = "192.168.1.101"  # IP Victron CCGX PORT: 1883 (default)
CLIENT_NAME = "IronTruck"
mqtt = MqttController(broker=BROKER, clientName=CLIENT_NAME)

# ********************************
READING_FREC = 5
KEEP_ALIVE = 30
# We now have running MQTT and InfluxDB database connection



network = SensorControllerSet()
def setup(network):
    # create Sensor 1 (DHT22)
    settings = SensorAlarmSettings(sensorId=0)._update(trigger=30, relay='00000001', alarmState=1)
    network.add(SensorController(DHT_22(pin=21, name="Habitacion de Mateo"),settings, influx, mqtt))
    mqtt.suscribeAll(settings)
    #TODO no deberia hacer falta el _update
    #TODO arreglar el tema del sensor_id
def sensors_read(network):
    for controller in network:
        controller.send_data()

def keep_alive_count (count):
    count += 1
    if(count * READING_FREC == KEEP_ALIVE):
        mqtt.keep_alive()
        count = 0
def main():
    count = 0
    setup(network)
    while True:

        sensors_read(network)
        keep_alive_count(count)
        time.sleep(READING_FREC)
        
        
main()
