import re



string = 'R/508cb1cb59e8/settings/0/Settings/RpiSensors/0/AlarmSetting'
prefix = 'R/508cb1cb59e8/settings/0/Settings/RpiSensors/'
ALARM = 0
RELAY = 1
TRIGGER = 2
ERROR = -1
def pattern_format(text):
    if bool(re.compile (r'Settings/RpiSensors/\d/Alarm($| )').search(text)): return ALARM
    if bool(re.compile (r'Settings/RpiSensors/\d/AlarmSetting($| )').search(text)): return RELAY
    if bool(re.compile (r'Settings/RpiSensors/\d/AlarmTrigger($| )').search(text)): return TRIGGER
    return ERROR
def pattern(text):
    res = re.compile (r'Settings/RpiSensors/\d/AlarmSetting($| )').search(text)
    sensor_id = int(text.replace(prefix, '')[0])
    if bool(res): return RELAY, sensor_id


print(pattern(string))
''' 
match pattern_format(string):
            case ALARM:
                pass
            case RELAY:
                pass
            
            case TRIGGER:
                pass
            case _:
                pass

'''  