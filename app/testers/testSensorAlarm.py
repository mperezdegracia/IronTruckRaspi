from sensor import *
from alarm import *
import time

sensor = Sensor('Mateo Test Sensor', 12)
alarm = Alarm(sensor, 1, 25)

while True:
    sensor.testing_read()
    print(f'{alarm} --> STATE[{alarm.detect()}]')
    time.sleep(2)
