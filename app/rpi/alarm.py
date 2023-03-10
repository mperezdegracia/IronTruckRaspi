from sensor import Sensor
from settings import SensorAlarmSettings
import logging

class Alarm(object):
    def __init__(self, sensor: Sensor, setting: SensorAlarmSettings, inverseTrigger=False) -> None:
        self.sensor = sensor
        self.settings = setting
        self.is_inverse = inverseTrigger
        self.is_active = False
        self.__last_state = False
        self.__state = False 


    def activate(self):
        logging.info(f'[ALARM] [ACTIVE] ---> {self.sensor}')
        self.is_active = True

    def deactivate(self):
        logging.info(f'[ALARM] [OFF] ---> {self.sensor}')
        self.is_active = False

    def is_stateValid(self):
        return self.sensor.state is not None
    
    def triggered(self):
        result =  self.__state != self.__last_state
        if result : 
            logging.info(f'[ALARM] [TRIGGERED] --> {self.sensor}')
        return result
        
    def get_state(self):
        return self.__state
    def detect(self) -> bool:
        if not self.is_stateValid() or not self.settings.isValid():
            raise InvalidAlarmSensorState(self)
        if self.__state:
            # Entonces la alarma ya está sonando, checkeamos con histéresis
            alarmState = self.sensor.state >= (self.settings.getTrigger()*(1- self.sensor.HYSTERESIS))
        else: 
            alarmState = self.sensor.state >= self.settings.getTrigger()

        alarmState = alarmState ^ self.is_inverse
        #print(f'[ALARM] [STATE]] ---> {alarmState} last: {self.__state}')
        
        self.__last_state = self.__state
        self.__state = alarmState
        
        return self.triggered() 



    def __str__(self) -> str:
        return f'[ALARM] ---> SENSOR: {self.sensor} | TRIGGER: {self.settings.getTrigger()} | INVERSE: {self.is_inverse}'

    def __del__(self):
        logging.debug(f'[DELETE] ---> ALARM to {self.sensor}') #print(f'[DELETE] ---> {self}')


class InvalidAlarmSensorState(Exception):
    def __init__(self, alarm: Alarm) -> None:
        super().__init__(
            f'[ERROR] -->  {alarm} INVALID SENSOR STATE ({alarm.sensor.state})')
