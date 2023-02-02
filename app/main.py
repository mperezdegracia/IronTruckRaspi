from mqtt import *
from influx import *
from sensor import *
from temp import *
from gas import *
from relay import *
from alarm import *
from register import *
import asyncio


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

# We now have running MQTT and InfluxDB database connection


class SensorController(object):
    def __init__(self, sensor: Sensor, settings: SensorAlarmSettings ,database: Influx, victron: MqttController) -> None:
        self.sensor = sensor
        self.alarm = Alarm(self.sensor, self.settings)
        self.settings = settings
        self.database = database
        self.victron = victron


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







network = SensorControllerSet()


def setup():
    # create Sensor 1 (DHT22)
    network.add(SensorController(DHT_22(pin=21, name="Habitacion de Mateo"),SensorAlarmSettings(sensorId=0)._update(trigger=30, relay='00000001', alarmState=1), influx, mqtt))
    #TODO no deberia hacer falta el _update
    #TODO arreglar el tema del sensor_id
def sensors_read(network):
    for controller in network:
        controller.send_data()



def main():
    
    setup()
    while True:
        sensors_read(network)
        time.sleep(4)


main()