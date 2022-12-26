import RPi.GPIO as GPIO
import time


class RelayController(object):

    # this class assumes the current pinout
    # RELAYS = [14,27,10,9,11,0,5,6] GPIO.BCM
    GPIO.setmode(GPIO.BCM)  # GPIO Numbers instead of board numbers
    # GPIO.setwarnings(False)
    RELAYS = [14, 27, 10, 9, 11, 0, 5, 6]  # [5,6,10,0,14,11,9,27]
    for pin in RELAYS:
        GPIO.setup(pin, GPIO.OUT, initial=GPIO.LOW)

    @staticmethod
    def turnON(relayNumber):
        relay = RelayController.RELAYS[relayNumber]
        GPIO.output(relay, GPIO.HIGH)

    @staticmethod
    def turnOFF(relayNumber):
        relay = RelayController.RELAYS[relayNumber]
        GPIO.output(relay, GPIO.LOW)


'''
RelayController.turnON(0)
time.sleep(3)
RelayController.turnOFF(0)


'''
