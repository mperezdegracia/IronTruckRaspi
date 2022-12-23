from temp import *
from gas import *
from sensor import Setting

LOCATION = 'Temp'
PIN = 21
CLAIMED = None
TYPE = "DHT22"
CONFIG = [
    '/508cb1cb59e8/dht/0/DHTSensor/0/State',
    '/508cb1cb59e8/settings/0/Settings/RpiSensors/0/AlarmTrigger',
    '/508cb1cb59e8/settings/0/Settings/RpiSensors/0/AlarmSetting',
    '/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm',
]

dht_settings = Setting(PIN)
dht = DHT_22(dht_settings)
dht._read()

LOCATION = 'Gas'
PIN = 0
CLAIMED = None
TYPE = "MQ2"
CONFIG = [
    '/508cb1cb59e8/mq2/0/GasSensor/0/State',
    '/508cb1cb59e8/settings/0/Settings/RpiSensors/1/AlarmTrigger',
    '/508cb1cb59e8/settings/0/Settings/RpiSensors/1/AlarmSetting',
    '/508cb1cb59e8/settings/0/Settings/RpiSensors/1/Alarm',
]

mq_settings = Setting(PIN)
mq2 = MQ2(mq_settings)
mq2._read()
