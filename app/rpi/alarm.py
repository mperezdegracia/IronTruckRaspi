from sensor import Sensor
from settings import SensorAlarmSettings
import logging

class Alarm:
    """Class representing an alarm triggered by a sensor."""

    def __init__(self, sensor: Sensor, setting: SensorAlarmSettings, inverse_trigger=False) -> None:
        """Initialize the alarm with a sensor, settings, and an optional inverse trigger."""
        self.sensor = sensor
        self.settings = setting
        self.is_inverse = inverse_trigger
        self.is_active = False
        self.state = False 

    def activate(self):
        """Activate the alarm."""
        logging.info(f'[ALARM] [ACTIVE] ---> {self.sensor}')
        self.is_active = True

    def deactivate(self):
        """Deactivate the alarm."""
        logging.info(f'[ALARM] [OFF] ---> {self.sensor}')
        self.is_active = False

    def is_state_valid(self):
        """Check if the sensor state is valid."""
        return self.sensor.state is not None
        
    def get_state(self):
        """Get the current state of the alarm."""
        return self.state

    def detect(self) -> bool:
        """Detect if the alarm should be triggered."""
        if not self.is_state_valid() or not self.settings.is_valid():
            raise InvalidAlarmSensorState(self)
        if self.state:
            # If the alarm is already sounding, check with hysteresis
            alarm_state = self.sensor.state >= (self.settings.get_trigger()*(1- self.sensor.HYSTERESIS))
        else: 
            alarm_state = self.sensor.state >= self.settings.get_trigger()

        alarm_state = alarm_state ^ self.is_inverse
        
        triggered =  self.state != alarm_state
        if triggered : 
            on = 'ON' if alarm_state else 'OFF'
            logging.info(f'[{self} [TRIGGERED] ({on}) --> {self.sensor}')

        self.state = alarm_state
        
        return triggered

    def __str__(self) -> str:
        """Return a string representation of the alarm."""
        return f'[ALARM] ---> SENSOR: {self.sensor} | TRIGGER: {self.settings.get_trigger()} | INVERSE: {self.is_inverse}'

    def __del__(self):
        """Log when the alarm is deleted."""
        logging.debug(f'[DELETE] ---> ALARM to {self.sensor}')


class InvalidAlarmSensorState(Exception):
    """Exception raised when the sensor state is invalid."""

    def __init__(self, alarm: Alarm) -> None:
        """Initialize the exception with the invalid alarm."""
        super().__init__(
            f'[ERROR] -->  {alarm} INVALID SENSOR STATE ({alarm.sensor.state})')