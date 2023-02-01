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


    def _read(self):
        pass

    def alarm_(self, inverse=False):

        print("alarm OFF FOR " + str(self.name)) if inverse else print("alarm ON FOR " + str(self.name)) 
        for x in enumerate(self.relay['value']):
            if x[1] == '1':
                on = 0 if inverse else 1
                index =  x[0] + 1
                print("relay num:" + str(index))
                path = 'W' + '/508cb1cb59e8/relays/0/Relay/' + str(index) +'/State'
                mqtt_client.publish( path,  json.dumps({'value': on}))

class DHT_22(SensorBase):

    def __init__(self, tree):
        super(DHT_22, self).__init__(tree)
        self.device = adafruit_dht.DHT22(Pin(self.pin))

    def update(self, topic, value):
        for setting in [self.state, self.trigger, self.relay, self.alarm]:
            if setting['path'] == topic:
                setting['value'] = value

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
         
            print("\n TEMP ***************************** \n")
            print("     Trigger: " + str(float(self.trigger['value']))) 
            print("     Alarm: " + str(int(self.alarm['value'])))
            print("     State: " + str(int(self.state['value']))) 
            print("     Value: " + str(temperature)) 
            if temperature > float(self.trigger['value']) and int(self.alarm['value']) == 1  and int(self.state['value']) == 1:
                mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 2}))
                self.alarm_()
            if ( temperature < float(self.trigger['value']) and int(self.state['value']) == 2 ) or int(self.alarm['value']) == 0 :
                mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 1}))
                print("alarm off for .. " + str(self.name))
                self.alarm_(inverse=True)
            return True  # successful


        except RuntimeError:
            # Errors happen fairly often, DHT's are hard to read, just keep going
            time.sleep(2.0)
            self._read()

        except Exception as error:
            print("error")
            print(error)
            return
            #mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 0}))
            #should log eventually



class MQ2(SensorBase):

    def __init__(self, tree):
        super(MQ2, self).__init__(tree)
        self.device = AnalogIn(ADS.ADS1115(busio.I2C(board.SCL, board.SDA)), self.pin)

    def update(self, topic, value):
        for setting in [self.state, self.trigger, self.relay, self.alarm]:
            if setting['path'] == topic:
                setting['value'] = value

    def _read(self):
        try:
            voltage = self.device.voltage
            PPM = round(26.572*math.exp(1.2894*voltage), 2)
            data = [{
                'measurement': self.name,
                'time': datetime.datetime.now(),
                'fields': {
                    'GAS(PPM)': PPM
                },
            }]
            client.write_points(data)
            #print("reading gas ... \n")
            #mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 1}))
            #alarm
            print("\n MQ2 ******************** \n")
            print("     Trigger value: " + str(float(self.trigger['value'])))
            print("     Alarm: " + str(int(self.alarm['value'])))
            print("     State: " + str(int(self.state['value'])))
            print("     Value: " + str(PPM)) 
            if PPM > float(self.trigger['value']) and int(self.alarm['value']) == 1 and int(self.state['value']) == 1:
                mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 2}))
                self.alarm_()
            if (PPM < float(self.trigger['value']) and int(self.state['value']) == 2)  or int(self.alarm['value']) == 0 :
                mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 1}))
                self.alarm_(inverse=True)
            return

        except Exception as error:
            print("error")
            print(error)
            #mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 0}))  # set State to 0





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
    print("data published ---> ")
    pass

def toggleRelay(relay, state, inverse=False):
    RELAYS = [14,27,10,9,11,0,5,6]
    #GPIO.setmode(GPIO.BCM) # GPIO indexs instead of board indexs
    #GPIO.setwarnings(False)
    relay -= 1
    relay_pin = RELAYS[relay]
    print("toggle relay " + str(relay) + "relay pin: " + str(relay_pin))
    GPIO.setup(relay_pin, GPIO.OUT) # GPIO Assign mode
    state = 0 if state == 1 else 1
    GPIO.output(relay_pin, GPIO.LOW) if state == 0 else GPIO.output(relay_pin,GPIO.HIGH)
    #GPIO.output(relay, GPIO.HIGH) #OFF
    
def on_message(client, userdata, message):
    time.sleep(1)
    try:
        _value = eval(message.payload)['value']
        _topic = message.topic[1:]
        if 'N/508cb1cb59e8/relays/0/Relay/' in message.topic and '/State' in message.topic :
            relay = int(message.topic.replace('N/508cb1cb59e8/relays/0/Relay/',"").replace('/State', ''))
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
                        print("updating " + str(_topic) + " to " +  str(_value))
                        device['CLAIMED'].update(_topic, _value)
                    else:
                        #print("updating... " + str(_topic)) 
                        i['value'] = _value
    except Exception as e:
        print(e)


if __name__ == '__main__':
    __metaclass__ = type
    VALUE_2_VOLTAGE = 4.096 / 32767.0
    #RELAYS = [14,27,10,9,11,0,5,6] #[5,6,10,0,14,11,9,27]
    GPIO.setmode(GPIO.BCM) # GPIO indexs instead of board indexs
    GPIO.setwarnings(False)
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
            'TYPE': "MQ2",
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
    broker = "192.168.1.100"  # PORT=1883 (DEFAULT)
    mqtt_client = mqtt.Client("sensores")  # create client object
    mqtt_client.on_publish = on_publish
    mqtt_client.on_message = on_message
    mqtt_client.connect(broker, port=1883,keepalive=60, bind_address="0.0.0.0")
    mqtt_client.loop_start()

    Sensors = []

    for device in devices:

        time.sleep(1)

        if device['TYPE'] == 'DHT22':
            sensor = DHT_22(device)
            device['CLAIMED'] = sensor
            Sensors.append(sensor)
        if device['TYPE'] == 'MQ2':
            sensor = MQ2(device)
            device['CLAIMED'] = sensor
            Sensors.append(sensor)
        for i in device['CONFIG']:
            topic = i['path']
            mqtt_client.subscribe('N'+ topic)
            mqtt_client.publish('R'+ topic)

    relay_paths = ['N/508cb1cb59e8/relays/0/Relay/1/State','N/508cb1cb59e8/relays/0/Relay/2/State',
                   'N/508cb1cb59e8/relays/0/Relay/3/State','N/508cb1cb59e8/relays/0/Relay/4/State',
                   'N/508cb1cb59e8/relays/0/Relay/5/State','N/508cb1cb59e8/relays/0/Relay/6/State',
                   'N/508cb1cb59e8/relays/0/Relay/7/State','N/508cb1cb59e8/relays/0/Relay/8/State']
    for relay in relay_paths:
        print("subscribing to relay ---> " + relay)
        mqtt_client.subscribe(relay)
    time.sleep(10)
    print(devices)
    def readSensor(sensor):
        while(True):
            
            print("checking for config changes --->")
            mqtt_client.publish('R' + sensor.trigger['path'])
            mqtt_client.publish('R' + sensor.relay['path'])
            mqtt_client.publish('R' + sensor.alarm['path'])
            time.sleep(3)
            sensor._read()
            

    threads = []

    for i in Sensors:
        process = Thread(target=readSensor, args=[i])
        process.start()
        threads.append(process)

    for process in threads:
        process.join()
       # measure()
