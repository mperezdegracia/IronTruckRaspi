from settings import SensorAlarmSettings
from temp import DHT_22
from gas import MQ2
from alarm import Alarm
# *********** INFLUX *************
HOST = "influxdb"  # Docker InfluxDB container running address
PORT = 8086
DATABASE_NAME = "IronTruck"


# ********************************

# *********** MQTT ***************

BROKER = "192.168.1.104"  # IP Victron CCGX PORT: 1883 (default)
CLIENT_NAME = "IronTruck"
KEEP_ALIVE = 30
PATH_SENSORS = 'N/508cb1cb59e8/settings/0/Settings/RpiSensors/'
PATH_RELAY = 'N/508cb1cb59e8/relays/0/Relay/'

# ********************************
READING_FREC = 8
# We now have running MQTT and InfluxDB database connection


# SENSORS 

s1 = DHT_22(pin=21, name="Habitacion de Mateo")
s2 = MQ2(pin=0, name="GAS Cocina")
DEVICES = {s1: Alarm(s1,SensorAlarmSettings(id=0)), s2:Alarm(s2,SensorAlarmSettings(id=0))}

