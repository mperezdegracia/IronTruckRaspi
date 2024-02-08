
'''
Abstract Sensor Class

'''
import random


class Sensor(object):
    HYSTERESIS = None
    def __init__(self, pin, name):
        self.pin = pin  # pin = id
        self.state = None
        self.name = name

    def __eq__(self, other: object) -> bool:
        if isinstance(other, self.__class__):
            return self.pin == other.pin
        return False
    
    def get_alarm_variable(self):
        pass
    '''
    Must be overloaded by subclasses
    '''
    def __hash__(self) -> int:
        return self.pin
    
    def __eq__(self, __value: object) -> bool:
        return self.pin == __value.pin and self.name == __value.name
    def read(self):
        # return JSON ? TODO
        return {}

    def testing_read(self):
        self.state = random.randrange(20, 40, 1)
        return self.state

    def __str__(self) -> str:
        return f'[{ __class__.__name__}] {self.name}({self.pin})'



