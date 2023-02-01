import paho.mqtt.client as mqtt
from influxdb import InfluxDBClient
import requests
import time
import datetime
import math
import pprint
import os
import signal
import sys
import argparse
import logging
import board
import busio
import adafruit_ads1x15.ads1115 as ADS
import adafruit_dht
from adafruit_ads1x15.analog_in import AnalogIn
from adafruit_blinka.microcontroller.bcm283x.pin import Pin
import RPi.GPIO as GPIO
import json
from threading import Thread

# relays=[{'LOCATION': 'test' ,'PIN': 0,'TYPE': 'RELAY','INITIAL': 0}]# PINS DEL GPIO
#buzzer =[{'LOCATION': 'test' ,'PIN': 0,'TYPE': 'BUZZER','INITIAL': 1}]


class SensorBase(object):
    def __init__(self, tree):
        self.name = tree['LOCATION']
        self.pin = tree['PIN']
        self.state = tree['CONFIG'][0]
        self.trigger = tree['CONFIG'][1]
        self.relay = tree['CONFIG'][2]
        self.alarm = tree['CONFIG'][3]

    def isAlive(self):
        pass

    def _read(self):
        pass

    def alarm_(self, inverse=False):
        for x in enumerate(self.relay['value']):
            if x[1] == '1':
                on = 0 if inverse else 1
                index =  x[0] + 1
                mqtt_client.publish("W" + '/508cb1cb59e8/relays/0/Relay/' + str(index) +'/State',  json.dumps({'value': on}))
                

class DDHT_22(SensorBase):

    def __init__(self, tree):
        super(DDHT_22, self).__init__(tree)
        self.device = adafruit_dht.DHT22(Pin(self.pin))
        self.isAlive()

    def update(self, topic, value):
        for setting in [self.state, self.trigger, self.relay, self.alarm]:
            if setting['path'] == topic:
                setting['value'] = value

    def isAlive(self):

        try:
            # Print the values to the serial port
            temperature = self.device.temperature
            humidity = self.device.humidity
            mqtt_client.publish(
                "W" + self.state['path'],  json.dumps({'value': 1}))
            return True
        except RuntimeError:
            # Errors happen fairly often, DHT's are hard to read, just keep going
            time.sleep(2.0)
            self._read()

        except Exception as error:
            mqtt_client.publish(
                "W" + self.state['path'],  json.dumps({'value': 0}))
            # set State to 0 not Connected
            return False

    def _read(self):
        try:
            # Print the values to the serial port
            temperature = self.device.temperature
            humidity = self.device.humidity
            data = [{
                'measurement': self.name,
                'time': datetime.datetime.now(),
                'fields': {
                    'temperature': round(temperature, 2),
                    'humidity': round(humidity, 2)
                },
            }]

            client.write_points(data)
            # ALARM
            if temperature > float(self.trigger['value']) and int(self.alarm['value']) and int(self.state['value']) == 1:
                mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 2}))
                self.alarm_()
            if (temperature < float(self.trigger['value']) and int(self.state['value']) == 2) or int(self.alarm['value']) == 0 :
                mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 1}))
                self.alarm_(inverse=True)
            return True  # successful

        except RuntimeError:
            # Errors happen fairly often, DHT's are hard to read, just keep going
            time.sleep(2.0)
            self._read()

        except Exception as e:
            print(e)
            return self.isAlive()
    


class MQ2(SensorBase):

    def __init__(self, tree):
        super(MQ2, self).__init__(tree)
        self.device = AnalogIn(ADS.ADS1115(
            busio.I2C(board.SCL, board.SDA)), self.pin)
        self.isAlive()

    def update(self, topic, value):
        for setting in [self.state, self.trigger, self.relay, self.alarm]:
            if setting['path'] == topic:
                setting['value'] = value

    def isAlive(self):
        try:
            voltage = self.device.voltage
            mqtt_client.publish(
                "W" + self.state['path'],  json.dumps({'value': 1}))  # set State to 1
            return True
        except:
            mqtt_client.publish(
                "W" + self.state['path'],  json.dumps({'value': 0}))  # set State to 0
            return False

    def _read(self):
        try:
            voltage = self.device.voltage
            PPM = 26.572*math.exp(1.2894*voltage)
            data = [{
                'measurement': self.name,
                'time': datetime.datetime.now(),
                'fields': {
                    'GAS(PPM)': round(PPM, 2)
                },
            }]
            client.write_points(data)
            return True  # successful

        except:
            return self.isAlive()

            


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


def connect_db(host, port):
    '''connect to the database, and create it if it does not exist'''
    global client
    print('connecting to database: {}:{}'.format(host, port))
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
    if not create and False:
       client.delete_series(measurement=measurement)


def on_publish(client, userdata, result):  # create function for callback
    print("data published --->")
    pass

def toggleRelay(relay, current, inverse=False):
    RELAYS = [14,27,10,9,11,0,5,6]
    GPIO.setmode(GPIO.BCM) # GPIO indexs instead of board indexs
    GPIO.setwarnings(False)
    relay -= 1
    GPIO.setup(RELAYS[relay], GPIO.OUT) # GPIO Assign mode
    if inverse:
        current = 0 if current == 1 else 1
    GPIO.output(RELAYS[relay], GPIO.LOW) if current else GPIO.output(RELAYS[relay],GPIO.HIGH)


def on_message(client, userdata, message):
    time.sleep(1)
    try:
        _value = eval(message.payload)['value']
        print(_value)
        _topic = message.topic[1:]
        if '/relays/0/Relay/' in message.topic and '/State' in message.topic :
            relay = int(message.topic.replace('N/508cb1cb59e8/relays/0/Relay/', "").replace("/State", ""))
            state = str(message.payload.decode("utf-8"))
            state = int(json.loads(state)['value'])
            toggleRelay(relay, state)
        global devices
        for device in devices:
            claimed = True
            if device['CLAIMED'] is None:
                claimed = False
            for i in device['CONFIG']:
                if i['path'] == _topic:
                    if claimed:
                        device['CLAIMED'].update(_topic, _value)
                    else:
                        i['value'] = _value
    except Exception as e:
        print(e)


if __name__ == '__main__':
    __metaclass__ = type
    VALUE_2_VOLTAGE = 4.096 / 32767.0
    #RELAYS = [14,27,10,9,11,0,5,6] #[5,6,10,0,14,11,9,27]
    client = None
    dbname = 'mydb'
    devices = [{
        'LOCATION': 'Temp',
        'PIN': 21,
        'CLAIMED': None,
        'TYPE': "DHT22",
        'CONFIG':
                [
                    dict(path = '/508cb1cb59e8/dht/0/DHTSensor/0/State', value = None),
                    dict(path = '/508cb1cb59e8/settings/0/Settings/RpiSensors/0/AlarmTrigger', value = None),
                    dict(path = '/508cb1cb59e8/settings/0/Settings/RpiSensors/0/AlarmSetting', value = None),
                    dict(path = '/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', value = None)
                ]
    },
        {
        'LOCATION': 'Gas',
            'PIN': 0,
            'CLAIMED': None,
            'TYPE': None,
            'CONFIG':
                [

                    dict(path = '/508cb1cb59e8/mq2/0/GasSensor/0/State', value = None),
                    dict(path = '/508cb1cb59e8/settings/0/Settings/RpiSensors/1/AlarmTrigger', value = None),
                    dict(path = '/508cb1cb59e8/settings/0/Settings/RpiSensors/1/AlarmSetting', value = None),
                    dict(path = '/508cb1cb59e8/settings/0/Settings/RpiSensors/1/Alarm', value = None)
                ]
    }]

    host = "influxdb"  # '192.168.12.142'
    port = 8086  # 3000
    # INFLUX DB CLIENT
    connect_db(host, port)
    # MQTT CLIENT
    broker = "192.168.12.159"  # PORT=1883 (DEFAULT)
    mqtt_client = mqtt.Client("sensores")  # create client object
    mqtt_client.on_publish = on_publish
    mqtt_client.on_message = on_message
    mqtt_client.connect(broker, 1883, bind_address="0.0.0.0")
    mqtt_client.loop_start()

    Sensors = []

    for device in devices:

        for i in device['CONFIG']:
            topic = i['path']
            mqtt_client.publish('R'+ topic)
            mqtt_client.subscribe('N'+ topic)

        time.sleep(4)

        if device['TYPE'] == 'DHT22':
            sensor = DDHT_22(device)
            device['CLAIMED'] = sensor
            Sensors.append(sensor)

        if device['TYPE'] == 'MQ2':
            sensor = MQ2(device)
            device['CLAIMED'] = sensor
            Sensors.append(sensor)
    relay_paths = ['N/508cb1cb59e8/relays/0/Relay/1/State','N/508cb1cb59e8/relays/0/Relay/2/State'
              ,'N/508cb1cb59e8/relays/0/Relay/3/State','N/508cb1cb59e8/relays/0/Relay/4/State',
              'N/508cb1cb59e8/relays/0/Relay/5/State','N/508cb1cb59e8/relays/0/Relay/6/State',
              'N/508cb1cb59e8/relays/0/Relay/7/State','N/508cb1cb59e8/relays/0/Relay/8/State']
    for relay in relay_paths:
        mqtt_client.subscribe(relay)
    def readSensor(sensor):
        while(True):
            result = sensor._read()
            time.sleep(5)
    while(True):
        for i in Sensors:
            sensor._read()

'''
    threads = []

    for i in Sensors:
        process = Thread(target=readSensor, args=[i])
        process.start()
        threads.append(process)

    for process in threads:
        process.join()
       # measure()
'''
