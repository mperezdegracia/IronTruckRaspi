
'''
Abstract Sensor Class

'''


class Sensor(object):
    def __init__(self, config):
        self.config = config

    '''
    Must be overloaded by subclasses
    '''

    def _read(self):
        pass


class Setting(object):
    def __init__(self, pin, state=None, trigger=None, relay=None, alarm=None):
        self.pin = pin
        self.state = state
        self.trigger = trigger
        self.relay = relay
        self.alarm = alarm
