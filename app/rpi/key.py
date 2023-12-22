# *********** INFLUX *************
HOST = "influxdb"  # Docker InfluxDB container running address
PORT = 8086
DATABASE_NAME = "IronTruck"


# ********************************

# *********** MQTT ***************

BROKER = "192.168.1.104"  # IP Victron CCGX PORT: 1883 (default)
CLIENT_NAME = "IronTruck"
KEEP_ALIVE = 30
# ********************************
READING_FREC = 8
# We now have running MQTT and InfluxDB database connection
