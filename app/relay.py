import RPi.GPIO as GPIO
import time


class RelayController(object):

    # this class assumes the current pinout
    # RELAYS = [14,27,10,9,11,0,5,6] GPIO.BCM
    GPIO.setmode(GPIO.BCM)  # GPIO Numbers instead of board numbers
    # GPIO.setwarnings(False)
    RELAYS = [14, 27, 10, 9, 11, 0, 5, 6]  # [5,6,10,0,14,11,9,27]
    for pin in RELAYS:
        GPIO.setup(pin, GPIO.OUT, initial=GPIO.HIGH)

    @staticmethod
    def turnON(relayNumber):
        relay = RelayController.RELAYS[relayNumber]
        GPIO.output(relay, GPIO.LOW)

    @staticmethod
    def turnOFF(relayNumber):
        relay = RelayController.RELAYS[relayNumber]
        GPIO.output(relay, GPIO.HIGH)

if __name__ == '__main__':

    for i in range(8):
        RelayController.turnOFF(i)
        time.sleep(1)
        RelayController.turnON(i)
