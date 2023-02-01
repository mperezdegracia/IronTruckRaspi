import math
import time
import board
import adafruit_dht
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
from adafruit_blinka.microcontroller.bcm283x.pin import Pin
dhtDevice = adafruit_dht.DHT22(Pin(21))
i2c = busio.I2C(board.SCL, board.SDA)
ads = ADS.ADS1115(i2c)
chan = AnalogIn(ads, 0)

while True:
    try:
        # Print the values to the serial port
        temperature_c = dhtDevice.temperature
        humidity = dhtDevice.humidity

    except RuntimeError as error:
        # Errors happen fairly often, DHT's are hard to read, just keep going
        print(error.args[0])
        time.sleep(2.0)
        continue
    except Exception as error:
        dhtDevice.exit()
        raise error

    PPM = round(26.572*math.exp(1.2894*chan.voltage),2)
    print(
            "Temp {:.1f} C    Humidity: {}%  PPM: {:.2f} ".format(
                temperature_c, humidity, PPM
            )
        )
 
    time.sleep(3)
