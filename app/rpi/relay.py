import RPi.GPIO as GPIO
import time
import logging



class RelayMask:
    def __init__(self,initial = 'xxxxxxxx') -> None:
        self._mask = initial

        
    def apply_to_mask(self, setting, inverse = False):  # setting = '00000000' each being '0'= Stays the same or '1' = Toggle
        if not setting:
            return
        
        for i,bit in enumerate(setting):
            if int(bit):
                value = (int(bit) ^ inverse) if self._mask[i] is 'x' else (int(bit) ^ inverse) or int(self._mask[i])
                self._mask  =  self._mask[:i] + str(value) + self._mask[i+1:]
    def reset(self):
        self._mask = 'xxxxxxxx'

    def __iter__ (self):
        return self._mask.__iter__()
    def get(self):
        return self._mask
    def __str__(self) -> str:
        return self._mask

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
        for pin in RELAYS_PINS:
          self.relays.append(Relay(pin))

    def get(self,relay_num):
        return self.relays[relay_num]
    

    def apply_mask(self,mask: RelayMask):
        self.apply_setting(mask.get())

    def state(self):
        current_state = ''
        for relay in self:
            current_state += str(relay.state())
        return current_state

    def apply_setting(self,setting: str):
        state = self.state()
        if(setting != state):
            for i, relay in enumerate(self):
                if(setting[i] != 'x'):
                    relay.set(int(setting[i]))

            logging.info(f'[RELAY] ---> RELAYS from {state} to {self.state()} CONFIGURATION')
            
            return True
        return False    

    def __iter__(self):
        return self.relays.__iter__()




def test(): 
    mask = RelayMask(initial= '00000000')
    RelayController.apply_mask('10000001')
    for i in range(30):
        mask.apply_to_mask('01100000')
        mask.apply_to_mask('00000100')
        RelayController.apply_mask(mask)
        mask.reset()
        print(f'State {RelayController.get_states()}')
        time.sleep(2)


if __name__ == '__main__':
    test()
    