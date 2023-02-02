from mqtt import *





mqtt_controller = MqttController('192.168.1.101', 1883)
settings = SensorAlarmSettings(0) # Settings() 
mqtt_controller.suscribeAll(settings)

#mqtt_controller.mqtt.subscribe('R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm')

while True:
    mqtt_controller.mqtt.publish(
        'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', json.dumps({'value': 1}), qos=1)
    time.sleep(4)
    mqtt_controller.mqtt.publish(
        'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/Alarm', json.dumps({'value': 0}), qos=1)



