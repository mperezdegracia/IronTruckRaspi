from sensor import *
from alarm import *
import time

sensor = Sensor('Mateo Test Sensor', 12)
setting = SensorAlarmSettings(0)
alarm = Alarm(sensor, setting)
setting_update = {
    setting.trigger: None,
    setting.relayMask: 0,
    setting.alarmState: 1,
}
setting.update(setting_update)
while True:
    sensor.testing_read()
    print(f'{alarm} --> STATE[{alarm.detect()}]')
    time.sleep(2)
