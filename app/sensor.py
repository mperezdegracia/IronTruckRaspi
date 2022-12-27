
'''
Abstract Sensor Class

'''
import random


class Sensor(object):
    def __init__(self, pin, name):
        self.pin = pin
        self.state = None
        self.name = name

    '''
    Must be overloaded by subclasses
    '''

    def _read(self):
        # return JSON ? TODO
        return {}

    def testing_read(self):
        self.state = random.randrange(20, 40, 1)
        return self.state

    def __str__(self) -> str:
        return f'[{ __class__.__name__}]  NAME: {self.name} | PIN: [{self.pin}]'
