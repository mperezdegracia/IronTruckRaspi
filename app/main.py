from depend import * 
from threading import Thread


time.sleep(60)
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
    
    setup(network)
    while True:

        sensors_read(network)
        keep_alive_count()
        time.sleep(READING_FREC)
        
        
main()