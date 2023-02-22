import RPi.GPIO as GPIO
import time
import logging



class RelayMask:
    def __init__(self,initial = '00000000') -> None:
        self.__mask = 0

        self.apply_to_mask(initial)
        
    def apply_to_mask(self, setting, inverse = False):  # setting = '00000000' each being '0'= Stays the same or '1' = Toggle
        self.__mask |= int(setting,2)
    
    def reset(self):
        self.__mask = 0

    def __iter__ (self):
        return f'{self.__mask:08b}'.__iter__()
    def get(self):
        return f'{self.__mask:08b}'

    def __str__(self) -> str:
        return self.get()

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
        set(not self.state())
    def set(self, new_state):
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
                relay.set(int(setting[i]))

            logging.info(f'[RELAY] ---> RELAYS from {state} to {self.state()} CONFIGURATION')
            
            return True
        return False

    def __iter__(self):
        return self.relays.__iter__()
    '''
    # this class assumes the current pinout
    # RELAYS = [14,27,10,9,11,0,5,6] GPIO.BCM
   
      # [5,6,10,0,14,11,9,27]
    relays = []
    for pin in RELAYS_PINS:
        relays.append(Relay(pin))

    @staticmethod
    def turnON(relay_number):
        RelayController.relays[relay_number].set(True)

    @staticmethod
    def turnOFF(relay_number):
        RelayController.relays[relay_number].set(False)


    @staticmethod
    def allOFF():
        logging.debug(f'[RELAY] TURNING ALL RELAYS ON')
        RelayController.apply_setting('00000000') 

    @staticmethod
    def allON():
        logging.debug(f'[RELAY] ---> TURNING ALL RELAYS ON')
        RelayController.apply_setting('11111111')
    
    @staticmethod
    def apply_mask(mask: RelayMask) :
        bitmask = mask.get()
        return RelayController.apply_setting(bitmask)
    
    @staticmethod
    def apply_setting(setting: str):
        current_state = RelayController.get_states()
        for relay_number, bit in enumerate(setting):
            if int(bit):
                RelayController.relays[relay_number].toggle()

        logging.info(f'[RELAY] ---> RELAYS from {current_state} to {RelayController.get_states()} CONFIGURATION')
        
        return setting != '00000000'
    @staticmethod
    def get_states():
        state = ''
        for relay in RelayController.RELAYS_PINS:
            state += '0' if GPIO.input(relay) else '1'
        
        return state
        
    '''
if __name__ == '__main__':
    '''
    RelayController.apply_mask(RelayMask('10000001'))
    time.sleep(2)
    RelayController.apply_mask(RelayMask('01111110'))
    time.sleep(2)
    RelayController.apply_mask(RelayMask('00000000'))
    time.sleep(2)
    RelayController.allON()
    time.sleep(2)
    RelayController.allOFF()


    '''

    mask = RelayMask(initial= '00000000')
    RelayController.apply_mask('10000001')
    while True:
        mask.apply_to_mask('01100000')
        mask.apply_to_mask('00000100')
        RelayController.apply_mask(mask)
        mask.reset()
        print(f'State {RelayController.get_states()}')
        time.sleep(2)

