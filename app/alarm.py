from sensor import Sensor


class Alarm(object):
    def __init__(self, sensor: Sensor, relay, triggerValue, inverseTrigger=False) -> None:
        self.sensor = sensor
        self.relay = relay
        self.trigger = triggerValue
        self.is_inverse = inverseTrigger

    def start(self):
        pass

    def is_stateValid(self):
        return self.sensor.state is not None

    def detect(self):
        if not self.is_stateValid():
            raise InvalidAlarmSensorState(self)
        alarmState = self.sensor.state <= self.trigger
        return alarmState if self.is_inverse else not alarmState

    def __str__(self) -> str:
        return f'[ALARM] ---> SENSOR: {self.sensor} | TRIGGER: {self.trigger} | INVERSE: {self.is_inverse}'

    def __del__(self):
        print(f'[DELETE] ---> {self}')


class InvalidAlarmSensorState(Exception):
    def __init__(self, alarm: Alarm) -> None:
        super().__init__(
            f'[ERROR] -->  {alarm} INVALID SENSOR STATE ({alarm.sensor.state})')
