
class Settings(object):
    def __init__(self) -> None:
        self.settings = {}

    def update(self, keyValue: dict):
        for key, newValue in keyValue.items():
            if(key in self.settings):
                self.settings[key] = newValue


class AlarmSettings(Settings):

    def __init__(self, sensorId) -> None:
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


class EmptySettingsException(Exception):
    def __init__(self, settings: Settings) -> None:
        super().__init__(
            f'[ERROR] Empty Settings'
        )
