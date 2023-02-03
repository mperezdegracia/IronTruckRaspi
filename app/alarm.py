from sensor import Sensor
from settings import SensorAlarmSettings


class Alarm(object):
    def __init__(self, sensor: Sensor, setting: SensorAlarmSettings, inverseTrigger=False) -> None:
        self.sensor = sensor
        self.settings = setting
        self.is_inverse = inverseTrigger
        self.is_active = False

    def start(self): #TODO
        pass
    
    def activate(self):
        self.is_active = True

    def deactivate(self):
        self.is_active = False

    def is_stateValid(self):
        return self.sensor.state is not None

    def detect(self):
        if not self.is_stateValid() or not self.settings.isValid():
            raise InvalidAlarmSensorState(self)
        alarmState = self.sensor.state <= self.settings.getTrigger()
        return alarmState if self.is_inverse else not alarmState

    def __str__(self) -> str:
        return f'[ALARM] ---> SENSOR: {self.sensor} | TRIGGER: {self.settings.getTrigger()} | INVERSE: {self.is_inverse}'

    def __del__(self):
        print(f'[DELETE] ---> ALARM to {self.sensor}') #print(f'[DELETE] ---> {self}')


class InvalidAlarmSensorState(Exception):
    def __init__(self, alarm: Alarm) -> None:
        super().__init__(
            f'[ERROR] -->  {alarm} INVALID SENSOR STATE ({alarm.sensor.state})')
