from sensor import Sensor
import time
import math
import board
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
import logging

class MQ2(Sensor):
    HYSTERESIS = 0.05 # 10% del trigger value
    def __init__(self, pin, name):
        super(MQ2, self).__init__(pin, name)
        self.device = AnalogIn(ADS.ADS1115(
            busio.I2C(board.SCL, board.SDA)), self.pin)

    def _read(self):
        try:
            voltage = self.device.voltage
            PPM = round(26.572 * math.exp(1.2894*voltage), 2)
            self.state = PPM
            logging.info(
                f'{self} READING: {PPM}')
            return {'gas': PPM}

        except Exception as error:
            print(f'ERROR ->{error}')
