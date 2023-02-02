
class Settings(object):
    def __init__(self) -> None:
        self.settings = {}

    def update(self, keyValue: dict):
        for key, newValue in keyValue.items():
            if(key in self.settings):
                self.settings[key] = newValue


class SensorAlarmSettings(Settings):

    def __init__(self, sensorId, initialSettings={}) -> None:
        super().__init__()
        settingsPath = f'/508cb1cb59e8/settings/0/Settings/RpiSensors/{sensorId}'
        self.trigger = f'{settingsPath}/AlarmTrigger'
        self.relayMask = f'{settingsPath}/AlarmSetting'
        self.alarmState = f'{settingsPath}/Alarm'
        self.settings = {
            self.trigger: None,
            self.relayMask: None,
            self.alarmState: None
        }
        self.update(initialSettings)

    def isValid(self):
        return (None not in self.settings.values())

    def getSettings(self):
        return self.settings

    def getTrigger(self):
        return self.settings[self.trigger]

    def getRelay(self):
        return self.settings[self.relayMask]

    def getState(self):
        return self.settings[self.alarmState]

    def _update(self, trigger, relay, alarmState):
        self.settings = {
            self.trigger: trigger,
            self.relayMask: relay,
            self.alarmState: alarmState
        }
        return self


class EmptySettingsException(Exception):
    def __init__(self, settings: Settings) -> None:
        super().__init__(
            f'[ERROR] Empty Settings'
        )
