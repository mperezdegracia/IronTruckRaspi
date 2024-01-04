import RPi.GPIO as GPIO
import time
import logging



class Relay(object):
    def __init__(self,pin, initial_state = False) -> None:
        GPIO.setmode(GPIO.BCM)  # GPIO Numbers instead of board numbers
        GPIO.setwarnings(False)
        if pin not in [14, 27, 10, 9, 11, 0, 5, 6]:
            raise "INVALID PIN"
        self.pin = pin
        GPIO.setup(self.pin, GPIO.OUT, initial=GPIO.LOW if initial_state else GPIO.HIGH)
    def state(self):
        return 0 if GPIO.input(self.pin) else 1
    def toggle(self):
        self.set_state(not self.state())
    def set_state(self, new_state):
        GPIO.output(self.pin, GPIO.LOW if new_state else GPIO.HIGH)


    
class RelayController(object):

    def __init__(self) -> None:
        self.relays = []
        RELAYS_PINS = [14, 27, 10, 9, 11, 0, 5, 6]
        self.mask = 'xxxxxxxx'
        for pin in RELAYS_PINS:
          self.relays.append(Relay(pin))

    def get(self,relay_num):
        return self.relays[relay_num]

    def state(self):
        current_state = ''
        for relay in self:
            current_state += str(relay.state())
        return current_state

    def update_mask(self, setting):
        old_mask = self.mask
        if old_mask == setting:
            return False
        for i in range(len(old_mask)):
            self.mask[i] = '1' if old_mask[i] or setting[i] else '0'
        return True
        # apply new mask


    def set_relay(self, relay_num, state):
        self.relays[relay_num].set_state(state)
        self.mask[relay_num] = '1' if state else '0'
        logging.info(f'[RELAY] ---> RELAY {relay_num} = {state}')


    # def apply_mask(self):
    #     state = self.state()
    #     if(self.mask != state):
    #         for i, relay in enumerate(self):
    #             if(self.mask[i] != 'x'):
    #                 relay.set(int(self.mask[i]))
    #         logging.info(f'[RELAY] ---> RELAYS from {state} to {self.state()} CONFIGURATION')
    #         return True
    #     return False    

    def __iter__(self):
        return self.relays.__iter__()




def test(): 
    pass


if __name__ == '__main__':
    test()
    