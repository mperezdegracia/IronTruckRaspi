class Settings:
    """Class representing a collection of settings."""

    def __init__(self) -> None:
        """Initialize an empty settings dictionary."""
        self.settings = {}

    def update(self, key_value: dict):
        """Update the settings with the given key-value pairs."""
        for key, new_value in key_value.items():
            if key in self.settings:
                self.settings[key] = new_value


class SensorAlarmSettings(Settings):
    """Class representing the settings for a sensor alarm."""

    def __init__(self, id, initial_settings={}) -> None:
        """Initialize the sensor alarm settings with an ID and optional initial settings."""
        super().__init__()
        self.id = id 
        settings_path = f'/508cb1cb59e8/settings/0/Settings/RpiSensors/{self.id}'
        self.trigger = f'{settings_path}/AlarmTrigger'
        self.relay_mask = f'{settings_path}/AlarmSetting'
        self.alarm_state = f'{settings_path}/Alarm'
        self.settings = {
            self.trigger: None,
            self.relay_mask: None,
            self.alarm_state: None
        }
        self.update(initial_settings)

    def is_valid(self):
        """Check if all settings are set (i.e., not None)."""
        return None not in self.settings.values()

    def get_settings(self):
        """Get the settings dictionary."""
        return self.settings

    def get_trigger(self):
        """Get the trigger setting."""
        return self.settings[self.trigger]

    def get_relay(self):
        """Get the relay mask setting."""
        return self.settings[self.relay_mask]

    def get_state(self):
        """Get the alarm state setting."""
        return self.settings[self.alarm_state]

    def _update(self, trigger, relay, alarm_state):
        """Update the settings with the given trigger, relay mask, and alarm state."""
        self.settings = {
            self.trigger: trigger,
            self.relay_mask: relay,
            self.alarm_state: alarm_state
        }
        return self


class EmptySettingsException(Exception):
    """Exception raised when the settings are empty."""

    def __init__(self, settings: Settings) -> None:
        """Initialize the exception with the empty settings."""
        super().__init__(f'[ERROR] Empty Settings')