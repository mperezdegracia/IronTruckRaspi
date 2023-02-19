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
dbusservice.add_path('/Sensor/Count', None, writeable=True)

dbusservice.add_path('/Sensors/0/State',1, writeable=True) # 0 No Alarm, 1 Alarm
dbusservice.add_path('/Sensors/1/State',1, writeable=True)
dbusservice.add_path('/Sensors/2/State',1, writeable=True)
dbusservice.add_path('/Sensors/3/State',1, writeable=True)
dbusservice.add_path('/Sensors/4/State',1, writeable=True)
dbusservice.add_path('/Sensors/5/State',1, writeable=True)
dbusservice.add_path('/Sensors/6/State',1, writeable=True)
dbusservice.add_path('/Sensors/7/State',1, writeable=True)
dbusservice.add_path('/Sensors/8/State',1, writeable=True)
dbusservice.add_path('/Sensors/9/State',1, writeable=True)

dbusservice.add_path('/Sensors/0/Name',"Sensor 0", writeable=True)
dbusservice.add_path('/Sensors/1/Name',"Sensor 1", writeable=True)
dbusservice.add_path('/Sensors/2/Name',"Sensor 2", writeable=True)
dbusservice.add_path('/Sensors/3/Name',"Sensor 3", writeable=True)
dbusservice.add_path('/Sensors/4/Name',"Sensor 4", writeable=True)
dbusservice.add_path('/Sensors/5/Name',"Sensor 5", writeable=True)
dbusservice.add_path('/Sensors/6/Name',"Sensor 6", writeable=True)
dbusservice.add_path('/Sensors/7/Name',"Sensor 7", writeable=True)
dbusservice.add_path('/Sensors/8/Name',"Sensor 8", writeable=True)
dbusservice.add_path('/Sensors/9/Name',"Sensor 9", writeable=True)
dbusservice.add_path('/Devices/0/Version', 'testversie')
print 'Connected to dbus, and switching over to gobject.MainLoop() (= event based)'
mainloop = gobject.MainLoop()
mainloop.run()

