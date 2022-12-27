from mqtt import *
from influx import *
from sensor import *
#from temp import *
#from gas import *
#from relay import *
from alarm import *
from register import *

'''
# *********** INFLUX *************

HOST = "influxdb"  # Docker InfluxDB container running address
PORT = 8086
DATABASE_NAME = "IronTruck"
influx = Influx(HOST, PORT)
influx.connect_db(DATABASE_NAME)

# ********************************

# *********** MQTT ***************

BROKER = "192.168.1.100"  # IP Victron CCGX PORT: 1883 (default)
CLIENT_NAME = "IronTruck"
mqtt = MqttController(BROKER, CLIENT_NAME)

# ********************************
'''
# We now have running MQTT and InfluxDB database connection


sensors = []
# create Sensor 1 (DHT22)
sensor = Sensor(pin=21, name="Habitacion de Mateo")
setting = SensorAlarmSettings(0)
alarm = Alarm(sensor, setting)
setting_update = {
    setting.trigger: 30,
    setting.relayMask: 0,
    setting.alarmState: 1,
}
setting.update(setting_update)

controller = {'Sensor': sensor, 'Alarm': alarm}


while True:
    print(f'Reading: {controller["Sensor"].testing_read()} \n')
    print(f'[ALARM]  {controller["Alarm"].detect()}')
    print('\n')
    time.sleep(4)
