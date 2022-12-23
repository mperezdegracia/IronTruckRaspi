
from sensor import Sensor
import time
import board
import adafruit_dht
from adafruit_blinka.microcontroller.bcm283x.pin import Pin


class DHT_22(Sensor):

    def __init__(self, config):
        super(DHT_22, self).__init__(config)
        self.device = adafruit_dht.DHT22(Pin(self.config.pin))

    def update(self, topic, value):
        for setting in [self.state, self.trigger, self.relay, self.alarm]:
            if setting['path'] == topic:
                setting['value'] = value

    def _read(self):
        try:
            # Print the values to the serial port
            temperature = self.device.temperature
            humidity = self.device.humidity

            return (temperature, humidity)  # successful

        except RuntimeError:
            pass

        except Exception as error:
            print(f'ERROR ---> {error}')
            return ()
