from influxdb import InfluxDBClient
import requests

import time
import datetime
import math
import pprint
import os
import signal
import sys
import board
import adafruit_dht
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
from adafruit_blinka.microcontroller.bcm283x.pin import Pin
client = None
dbname = 'mydb'
measurement = 'sinwave'


def db_exists():
    '''returns True if the database exists'''
    dbs = client.get_list_database()
    for db in dbs:
        if db['name'] == dbname:
            return True
    return False

def wait_for_server(host, port, nretries=5):
    '''wait for the server to come online for waiting_time, nretries times.'''
    url = 'http://{}:{}'.format(host, port)
    waiting_time = 1
    for i in range(nretries):
        try:
            requests.get(url)
            return 
        except requests.exceptions.ConnectionError:
            print('waiting for', url)
            time.sleep(waiting_time)
            waiting_time *= 2
            pass
    print('cannot connect to', url)
    sys.exit(1)

def connect_db(host, port, reset):
    '''connect to the database, and create it if it does not exist'''
    global client
    print('connecting to database: {}:{}'.format(host,port))
    client = InfluxDBClient(host, port, retries=5, timeout=1)
    wait_for_server(host, port)
    create = False
    if not db_exists():
        create = True
        print('creating database...')
        client.create_database(dbname)
    else:
        print('database already exists')
    client.switch_database(dbname)
    if not create and reset:
        client.delete_series(measurement=measurement)

    
def measure(nmeas):
    '''insert dummy measurements to the db.
    nmeas = 0 means : insert measurements forever. 
    '''
    i = 0
    if nmeas==0:
        nmeas = sys.maxsize
    for i in range(nmeas):
        x = i/10.
        y = math.sin(x)
        try:
            # Print the values to the serial port
            temperature = dhtDevice.temperature
            humidity = dhtDevice.humidity

        except RuntimeError as error:
            # Errors happen fairly often, DHT's are hard to read, just keep going
            print(error.args[0])
            time.sleep(2.0)
            continue
        except Exception as error:
            dhtDevice.exit()
            raise error
        PPM = round(26.572*math.exp(1.2894*chan.voltage),2)
        data = [{
            'measurement':measurement,
            'time':datetime.datetime.now(),
            'tags': {
                'x' : x
                },
                'fields' : {
                    'y' : y
                    },
                },


		{
                'measurement': "temp",
                'time': datetime.datetime.now(),
                'fields': {
                    'temperature': round(temperature, 2),
                    'humidity': round(humidity, 2)
                          }
 	        },
		{
                'measurement': "gas",
                'time': datetime.datetime.now(),
                'fields': {
                    'GAS(PPM)': PPM
                }
                }
	]

        client.write_points(data)
        pprint.pprint(data)
        time.sleep(4)

def get_entries():
    '''returns all entries in the database.'''
    results = client.query('select * from {}'.format(measurement))
    # we decide not to use the x tag
    return list(results[(measurement, None)])

    
if __name__ == '__main__':
    import sys
    
    from optparse import OptionParser
    parser = OptionParser('%prog [OPTIONS] <host> <port>')
    parser.add_option(
        '-r', '--reset', dest='reset',
        help='reset database',
        default=False,
        action='store_true'
        )
    parser.add_option(
        '-n', '--nmeasurements', dest='nmeasurements',
        type='int', 
        help='reset database',
        default=0
        )
    
    options, args = parser.parse_args()
    if len(args)!=2:
        parser.print_usage()
        print('please specify two arguments')
        sys.exit(1)
    host, port = args
    connect_db(host, port, options.reset)
    def signal_handler(sig, frame):
        print()
        print('stopping')
        pprint.pprint(get_entries())
        sys.exit(0)
    signal.signal(signal.SIGINT, signal_handler)
    dhtDevice = adafruit_dht.DHT22(Pin(21))
    i2c = busio.I2C(board.SCL, board.SDA)
    ads = ADS.ADS1115(i2c)
    chan = AnalogIn(ads, 0)

    measure(options.nmeasurements)
        
    pprint.pprint(get_entries())
