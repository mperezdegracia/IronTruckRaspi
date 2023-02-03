import RPi.GPIO as GPIO
import time

class RelayMask:
    def __init__(self,initial = '00000000') -> None:
        self.__mask = 0
        self.apply_to_mask(initial)
        
    def apply_to_mask(self, setting, inverse = False):  # setting = '00000000' each being '0' or '1'
        self.__mask |= int(setting,2)
    
    def invert(self):
        self.__mask ^= 0
    
    def reset(self):
        self.__mask = 0
    
    def __iter__ (self):
        return self.__mask.__iter__()
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
        RelayController.apply_setting('00000000')

    @staticmethod
    def allON():
        RelayController.apply_setting('11111111')
    
    @staticmethod
    def apply_mask(mask: RelayMask):
        bitmask = mask.get()
        RelayController.apply_setting(bitmask)

    def apply_setting(setting: str):
        for relay_number, bit in enumerate(setting):
            RelayController.turnON(relay_number) if int(bit) else RelayController.turnOFF(relay_number)
            #print(f'RELAY NUMBER: {relay_number} , bit : {bit}')
            
if __name__ == '__main__':

    RelayController.apply_mask(RelayMask('10000001'))
    time.sleep(2)
    RelayController.apply_mask(RelayMask('01111110'))
    time.sleep(2)
    RelayController.apply_mask(RelayMask('00000000'))
    time.sleep(2)
    RelayController.allON()
    time.sleep(2)
    RelayController.allOFF()
