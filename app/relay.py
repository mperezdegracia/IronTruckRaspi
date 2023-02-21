import RPi.GPIO as GPIO
import time
import logging
class RelayMask:
    def __init__(self,initial = '00000000') -> None:
        self.__mask = 0
        self.apply_to_mask(initial)
        
    def apply_to_mask(self, setting, inverse = False):  # setting = '00000000' each being '0' or '1'
        self.__mask |= int(setting,2)
    
    def invert(self):
        self.__mask ^= 0
    
    def reset(self):
        # estados de los relays  - relayMask
        self.__mask ^= int(RelayController.get_states(),2)

    def __iter__ (self):
        return f'{self.__mask:08b}'.__iter__()
    def get(self):
        return f'{self.__mask:08b}'
class RelayController(object):

    # this class assumes the current pinout
    # RELAYS = [14,27,10,9,11,0,5,6] GPIO.BCM
    GPIO.setmode(GPIO.BCM)  # GPIO Numbers instead of board numbers
    GPIO.setwarnings(False)
    RELAYS = [14, 27, 10, 9, 11, 0, 5, 6]  # [5,6,10,0,14,11,9,27]

    for pin in RELAYS:
        GPIO.setup(pin, GPIO.OUT, initial=GPIO.HIGH)

    @staticmethod
    def turnON(relay_number):
        relay = RelayController.RELAYS[relay_number]
        GPIO.output(relay, GPIO.LOW)

    @staticmethod
    def turnOFF(relay_number):
        relay = RelayController.RELAYS[relay_number]
        GPIO.output(relay, GPIO.HIGH)
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
        if (setting != current_state):
            logging.info(f'[RELAY] ---> RELAYS from {current_state} to {setting} CONFIGURATION')

            for relay_number, bit in enumerate(setting):
                if int(bit):
                    RelayController.turnON(relay_number) 
                else:
                    RelayController.turnOFF(relay_number)
            RelayController.CURRENT_SETTING = setting
            return True
        return False
    @staticmethod
    def get_states():
        state = ''
        for relay in RelayController.RELAYS:
            state += '0' if GPIO.input(relay) else '1'
        
        return state
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

