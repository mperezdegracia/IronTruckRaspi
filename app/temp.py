
from sensor import Sensor
import time
import board
import adafruit_dht
from adafruit_blinka.microcontroller.bcm283x.pin import Pin


class DHT_22(Sensor):

    def __init__(self, pin, name):
        super(DHT_22, self).__init__(pin, name)
        self.device = adafruit_dht.DHT22(Pin(self.pin))

    def _read(self):
        try:
            # Print the values to the serial port
            temperature = self.device.temperature
            humidity = self.device.humidity
            self.state = temperature

            print(
                f'{self} --> READING: temperature: {round(temperature,2)} , humidity: {round(humidity,2)}')
            # successful
            return {'temperature': temperature, 'humidity': humidity}

        except RuntimeError:
            pass

        except Exception as error:
            print(f'ERROR ---> {error}')
            return ()
