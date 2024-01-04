
import threading
import time
from .influx import Influx
from .mqtt import MqttController
from .manager import Manager
from .controller import SensorController
from .alarm import SensorAlarmSettings
from .temp import DHT_22
from .gas import MQ2
from .key import *
from .relay import RelayController




time.sleep(20)

class NamedTimer(threading.Timer):
    def __init__(self, interval, function, name, args=None, kwargs=None):
        super().__init__(interval, function, args, kwargs)
        self.name =  name

def setup():
    pass
    

def run_thread():
    NamedTimer(READING_FREC, run_thread, name="Sensors").start()  # Run the function every 5 seconds
    manager.read()

def keep_alive_thread():
    NamedTimer(KEEP_ALIVE, keep_alive_thread, name= "Keep Alive").start()  # Run the function every 5 seconds
    manager.mqtt.keep_alive()


   
        

if __name__ == "__main__":
    manager = Manager()
    keep_alive_thread()
    run_thread()

   