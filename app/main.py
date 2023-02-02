from depend import * 
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




def setup(network):
    # create Sensor 1 (DHT22)
    settings = SensorAlarmSettings(sensorId=0)._update(trigger=30, relay='00000001', alarmState=1)
    network.add(SensorController(DHT_22(pin=21, name="Habitacion de Mateo"),settings, influx, mqtt))
    mqtt_controller.suscribeAll(settings)
    #TODO no deberia hacer falta el _update
    #TODO arreglar el tema del sensor_id
def sensors_read(network):
    for controller in network:
        controller.send_data()



def main():
    
    setup(network)
    time.sleep(60)
    while True:
        sensors_read(network)
        time.sleep(4)


main()