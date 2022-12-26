import paho.mqtt.client as paho
import json
import time


devices = [{
    'LOCATION': 'Temp',
    'PIN': 21,
    'CLAIMED': None,
    'TYPE': "DHT22",
    'STATE': {'N/508cb1cb59e8/system/0/RpiSensors/0/State': None},
    'TRIGGER': {'N/508cb1cb59e8/settings/0/Settings/RpiSensors/0/AlarmTrigger': None},
    'RELAY': {'N/508cb1cb59e8/settings/0/Settings/RpiSensors/0/AlarmSetting': None},
    'ALARM': {'N/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm': None}
},
    {
    'LOCATION': 'Gas',
        'PIN': 0,
        'CLAIMED': None,
        'TYPE': "MQ2",
        'STATE': {'N/508cb1cb59e8/system/0/RpiSensors/1/State': None},
        'TRIGGER': {'N/508cb1cb59e8/settings/0/Settings/RpiSensors/1/AlarmTrigger': None},
        'RELAY': {'N/508cb1cb59e8/settings/0/Settings/RpiSensors/1/AlarmSetting': None},
        'ALARM': {'N/508cb1cb59e8/settings/0/Settings/RpiSensors/1/Alarm': None}
}
]
top = {}

# MQTT INIT


def on_publish(client, userdata, result):  # create function for callback
    print("data published ")
    pass


def on_message(client, userdata, message):
    time.sleep(1)
    #print("message received " ,str(message.payload.decode("utf-8")))
    print(f'message topic= {message.topic}, {message.payload}')
    #print("message qos=",message.qos)
    # print("message retain flag=",message.retain)


broker = "192.168.1.102"
port = 1883

mqtt_client = paho.Client("control1")  # create client object
mqtt_client.on_publish = on_publish
mqtt_client.on_message = on_message
mqtt_client.connect(broker, port, bind_address="0.0.0.0")
mqtt_client.loop_start()

for device in devices:
    for key, props in device.items():
        if type(props) == dict:
            for topic, value in props.items():
                #print(topic, value)
                mqtt_client.subscribe(topic)
                read_topic = 'R' + topic[1:]
                time.sleep(2)
                mqtt_client.publish(read_topic)
for i in range(8):
    setting = list("00000000")
    setting[i] = '1'
    setting = ''.join(setting)
    path = '/508cb1cb59e8/settings/0/Settings/RpiSensors/' + \
        str(i) + '/AlarmSetting'
    mqtt_client.publish(
        "W" + path,  json.dumps({'value': setting}))
mqtt_client.loop_stop()
