import RPi.GPIO as GPIO
import time

class RelayMask:
    def __init__(self,initial = '00000000') -> None:
        self.__mask = 0
        self.__mask =  self.apply_to_mask(initial)
        
    def apply_to_mask(self, setting, inverse = False):  # setting = '00000000' each being '0' or '1'
        self.__mask |= int(setting,2)

    def __iter__ (self):
        return self.__mask.__iter__()

class RelayController(object):

    # this class assumes the current pinout
    # RELAYS = [14,27,10,9,11,0,5,6] GPIO.BCM
    GPIO.setmode(GPIO.BCM)  # GPIO Numbers instead of board numbers
    # GPIO.setwarnings(False)
    RELAYS = [14, 27, 10, 9, 11, 0, 5, 6]  # [5,6,10,0,14,11,9,27]
    for pin in RELAYS:
        GPIO.setup(pin, GPIO.OUT, initial=GPIO.HIGH)

    @staticmethod
    def turnON(relay_number):
        relay = RelayController.RELAYS[relay_number]
        GPIO.output(relay, GPIO.HIGH)

    @staticmethod
    def turnOFF(relay_number):
        relay = RelayController.RELAYS[relay_number]
        GPIO.output(relay, GPIO.LOW)

    @staticmethod
    def apply_mask(self, mask: RelayMask):
        for relay_number, bit in enumerate(f'{mask:08b}'):
            self.turnON(relay_number) if int(bit) else self.turnOFF(relay_number)

if __name__ == '__main__':

    for i in range(8):
        #RelayController.turnON(i)
        #time.sleep(1)
        #RelayController.turnOFF(i)
        RelayController.apply_mask(RelayMask('10000001'))
        time.sleep(2)
        RelayController.apply_mask(RelayMask('01111110'))
        time.sleep(2)
        RelayController.apply_mask(RelayMask('00000000'))

