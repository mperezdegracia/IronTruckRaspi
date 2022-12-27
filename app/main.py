from mqtt import *
from influx import *
from sensor import *
from temp import *
from gas import *
from relay import *
from alarm import *
from register import *


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
    def __init__(self, sensor: Sensor, database: Influx, victron: MqttController) -> None:
        self.sensor = sensor
        self.alarm = None
        self.database = database
        self.victron = victron

    def has_alarm(self):
        return self.alarm is not None

    def create_alarm(self, settings: SensorAlarmSettings, inverse=False):
        self.alarm = Alarm(self.sensor, settings, inverse)

    def delete_alarm(self):
        self.alarm = None

    def send_data(self):
        data = {
            'measurement': self.sensor.name,
            'time': datetime.datetime.now(),
            'fields': {
            },
        }
        fields = data['fields']
        for measurement, value in self.sensor._read().items():
            fields[measurement] = value

        self.database.client.write(data)

        if(self.has_alarm()):
            state = self.alarm.detect()
            if(state):
                # write something to database TODO
                for index, value in enumerate(self.alarm.settings.getRelay()):
                    if(value == '1'):
                        RelayController.turnON(index)

        return


sensors = []
# create Sensor 1 (DHT22)
sensor = DHT_22(pin=21, name="Habitacion de Mateo")
setting = SensorAlarmSettings(0)._update(30, '00000001', 1)
alarm = Alarm(sensor, setting)

controller = SensorController(sensor, influx, mqtt)

while True:
    controller.send_data()
    time.sleep(4)
