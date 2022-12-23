import RPi.GPIO as GPIO
import time
import paho.mqtt.client as paho
import json
GPIO.setmode(GPIO.BCM) # GPIO Numbers instead of board numbers
GPIO.setwarnings(False)
RELAYS = [14,27,10,9,11,0,5,6] #[5,6,10,0,14,11,9,27]
#GPIO.setup(20, GPIO.OUT) # GPIO Assign mode
#GPIO.output(20, GPIO.HIGH) # on
time.sleep(3)
#GPIO.output(20, GPIO.LOW) # off


for relay in RELAYS:
    GPIO.setup(relay, GPIO.OUT) # GPIO Assign mode
    GPIO.output(relay, GPIO.LOW) # off
    time.sleep(2)
    GPIO.output(relay, GPIO.HIGH) # on

'''
def switchRelay(number, state):
    global RELAYS
    #if number >  len(RELAYS): 
    #   print('wrong pin!')
    #    return
    #GPIO.setmode(GPIO.BCM) # GPIO Numbers instead of board numbers
    #GPIO.setwarnings(False)
    number =  number - 1 
    GPIO.setup(RELAYS[number], GPIO.OUT) # GPIO Assign mode
    GPIO.output(RELAYS[number], GPIO.LOW) if state else GPIO.output(RELAYS[number],GPIO.HIGH)
def on_publish(client,userdata,result):             #create function for callback
    print("data published ")
    pass

def on_message(client, userdata, message):
    
    relay = int(message.topic.replace('N/508cb1cb59e8/relays/0/Relay/', "").replace("/State", ""))
    state = str(message.payload.decode("utf-8"))
    state = int(json.loads(state)['value'])
    switchRelay(relay, state)
    #print("message qos=",message.qos)
    # print("message retain flag=",message.retain)

broker="192.168.12.148"
port=1883

mqtt_client= paho.Client("control1")                           #create client object
mqtt_client.on_publish = on_publish
mqtt_client.on_message=on_message  
mqtt_client.connect(broker,port, bind_address="0.0.0.0")
mqtt_client.loop_start()
relay_paths = ['N/508cb1cb59e8/relays/0/Relay/1/State','N/508cb1cb59e8/relays/0/Relay/2/State'
              ,'N/508cb1cb59e8/relays/0/Relay/3/State','N/508cb1cb59e8/relays/0/Relay/4/State',
              'N/508cb1cb59e8/relays/0/Relay/5/State','N/508cb1cb59e8/relays/0/Relay/6/State',
              'N/508cb1cb59e8/relays/0/Relay/7/State','N/508cb1cb59e8/relays/0/Relay/8/State']
for relay in relay_paths:
    
    mqtt_client.subscribe(relay)
for relay in relay_paths:

    read_topic = 'R' + relay[1:]
    mqtt_client.publish(read_topic)
    
while(True):
    pass
mqtt_client.loop_stop()


    
    
'''
