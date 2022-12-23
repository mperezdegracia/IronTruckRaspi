from sensor import Sensor
import time
import board
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn


class MQ2(Sensor):

    def __init__(self, tree):
        super.__init__(tree)
        self.device = AnalogIn(ADS.ADS1115(
            busio.I2C(board.SCL, board.SDA)), self.config.pin)

    def _read(self):
        try:
            voltage = self.device.voltage
            PPM = round(26.572*math.exp(1.2894*voltage), 2)
            return (PPM)

        except Exception as error:
            print("error")
            print(error)
            # mqtt_client.publish("W" + self.state['path'],  json.dumps({'value': 0}))  # set State to 0
