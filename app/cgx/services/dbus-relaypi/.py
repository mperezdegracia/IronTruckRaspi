#!/usr/bin/env python

## @package conversions
# takes data from the dbus, does calculations with it, and puts it back on
from dbus.mainloop.glib import DBusGMainLoop
import gobject
from gobject import idle_add
import dbus
import dbus.service
import inspect
import platform
from threading import Timer
import argparse
import logging
import sys
import os
import time
# our own packages
sys.path.insert(1, os.path.join(os.path.dirname(__file__), './ext/velib_python'))
from vedbus import VeDbusService
from vedbus import VeDbusItemImport
from settingsdevice import SettingsDevice
import threading
import time
dbusservice = None
''' 
def endSnooze(index):
	try:
	    dbusservice['/DHTSensor/'+ index +'/State'] = 2
	except Exception as e:
	    print(e)
'''
'''def update():
	for i in range(5):
	    index= str(i)
            relayNumber = str(settings['activate'+ index]) if str(settings['activate'+ index]) != "N" else "1"
            DHT_PIN = int(dbusservice['/DHTSensor/'+ index +'/Pin'])
            humidity, temperature = Adafruit_DHT.read(DHT_SENSOR, DHT_PIN)
            if humidity is not None and temperature is not None:
                dbusservice['/DHTSensor/'+ index +'/Temperature']= round(temperature,2)
                dbusservice['/DHTSensor/'+ index +'/Humidity']= round(humidity,2)
		
		on = 1 if VeDbusItemImport(bus, serviceName = 'com.victronenergy.settings', path='/Settings/Relay'+relayNumber+'/InitialState', createsignal=False).get_value() == 0 else 0
	    	off = 0 if on == 1 else 1
           	relay = VeDbusItemImport(bus, serviceName = 'com.victronenergy.system', path='/Relay/'+relayNumber+'/State', createsignal=False)
               	dbusservice['/DHTSensor/'+ index +'/Connected'] = 1
		if dbusservice['/DHTSensor/'+ index +'/State'] == 5:
		    continue

		if dbusservice['/DHTSensor/'+ index +'/State'] == 4:
                    relay.set_value(off)
    	            t = threading.Timer(300.0, endSnooze,args=[index])
        	    t.start()
                    dbusservice['/DHTSensor/'+ index +'/State'] = 5
		    continue
            	if settings['talarm'+index] == "N":
                    dbusservice['/DHTSensor/'+ index +'/State'] = 1 # El sensor esta activado pero no hay una alarma configurada
		    relay.set_value(off) 
		    continue
                else:
                    if temperature >= float(settings['talarm'+index]):
			dbusservice['/DHTSensor/'+index+'/State'] = 3 # la alarma esta sonando   
                        relay.set_value(on)
		    else:
                        relay.set_value(off)
			dbusservice['/DHTSensor/'+ index +'/State'] = 2 # hay una alarma configurada
		    continue	
	            

            else:
		dbusservice['/DHTSensor/'+ index +'/Connected'] = 0
	
        gobject.timeout_add(1000, update) '''

def handle_changed_setting(setting, oldvalue, newvalue):
    pass
# Argument parsing
parser = argparse.ArgumentParser(
	description='dbusMonitor.py demo run'
)

parser.add_argument("-n", "--name", help="the D-Bus service you want me to claim",
				type=str, default="com.victronenergy.dht")

parser.add_argument("-i", "--deviceinstance", help="the device instance you want me to be",
				type=str, default="0")

parser.add_argument("-d", "--debug", help="set logging level to debug",
				action="store_true")

args = parser.parse_args()

# Init logging
logging.basicConfig(level=(logging.DEBUG if args.debug else logging.INFO))
logging.info(__file__ + " is starting up")
logLevel = {0: 'NOTSET', 10: 'DEBUG', 20: 'INFO', 30: 'WARNING', 40: 'ERROR'}
logging.info('Loglevel set to ' + logLevel[logging.getLogger().getEffectiveLevel()])

# Have a mainloop, so we can send/receive asynchronous calls to and from dbus
DBusGMainLoop(set_as_default=True)

dbusservice = VeDbusService(args.name)
bus = dbus.SessionBus() if 'DBUS_SESSION_BUS_ADDRESS' in os.environ else dbus.SystemBus()

logging.info("using device instance %s" % args.deviceinstance)

# Create the management objects, as specified in the ccgx dbus-api document
dbusservice.add_path('/Management/ProcessName', __file__)
dbusservice.add_path('/Management/ProcessVersion', 'Unkown version, and running on Python ' + platform.python_version())
dbusservice.add_path('/Management/Connection', 'Data taken from mk2dbus')

# Create the mandatory objects
dbusservice.add_path('/DeviceInstance', args.deviceinstance)
dbusservice.add_path('/ProductId', 0)
dbusservice.add_path('/ProductName', 'vebus device with ac sensors')
dbusservice.add_path('/FirmwareVersion', 0)
dbusservice.add_path('/HardwareVersion', 0)
dbusservice.add_path('/Connected', 1)

# Create all the objects that we want to export to the dbus
dbusservice.add_path('/DHTSensor/Count', None, writeable=True)

dbusservice.add_path('/DHTSensor/0/Location', "Undefined")
dbusservice.add_path('/DHTSensor/0/Pin', 21)
dbusservice.add_path('/DHTSensor/0/State', 1,  writeable=True)

dbusservice.add_path('/DHTSensor/1/Location', "Undefined")
dbusservice.add_path('/DHTSensor/1/Pin', 0)
dbusservice.add_path('/DHTSensor/1/State',1, writeable=True)



dbusservice.add_path('/DHTSensor/2/Location',"Undefined")
dbusservice.add_path('/DHTSensor/2/Pin', 0)
dbusservice.add_path('/DHTSensor/2/State',1, writeable=True)


dbusservice.add_path('/DHTSensor/3/Location', "Undefined")
dbusservice.add_path('/DHTSensor/3/Pin', 0)
dbusservice.add_path('/DHTSensor/3/State',1, writeable=True)


dbusservice.add_path('/DHTSensor/4/Location', "Undefined")
dbusservice.add_path('/DHTSensor/4/Pin', 0)
dbusservice.add_path('/DHTSensor/4/State',1, writeable=True)


dbusservice.add_path('/Devices/0/Version', 'testversie')
settings = SettingsDevice(
		bus,
		supportedSettings={
            'talarm0': ['/Settings/DHTSensor/0/TAlarm', "N", 0, 0],
            'activate0':  ['/Settings/DHTSensor/0/Relay',"N", 0, 0],
            'halarm0': ['/Settings/DHTSensor/0/HAlarm', "N", 0, 0],
            'talarm1': ['/Settings/DHTSensor/1/TAlarm', "N", 0, 0],
            'activate1':  ['/Settings/DHTSensor/1/Relay', "N", 0, 0],
            'halarm1': ['/Settings/DHTSensor/1/HAlarm', "N", 0, 0],
            'talarm2': ['/Settings/DHTSensor/2/TAlarm',"N", 0, 0],
            'activate2':  ['/Settings/DHTSensor/2/Relay',"N", 0, 0],
            'halarm2': ['/Settings/DHTSensor/2/HAlarm', "N", 0, 0],
            'talarm3': ['/Settings/DHTSensor/3/TAlarm', "N", 0, 0],
            'activate3':  ['/Settings/DHTSensor/3/Relay',"N", 0, 0],
            'halarm3': ['/Settings/DHTSensor/3/HAlarm', "N", 0, 0],
            'talarm4': ['/Settings/DHTSensor/4/TAlarm', "N", 0, 0],
            'activate4':  ['/Settings/DHTSensor/4/Relay',"N", 0, 0],
            'halarm4': ['/Settings/DHTSensor/4/HAlarm', "N", 0, 0],
			},
		eventCallback=lambda *args: handle_changed_setting( *args))



print 'Connected to dbus, and switching over to gobject.MainLoop() (= event based)'
mainloop = gobject.MainLoop()
mainloop.run()

