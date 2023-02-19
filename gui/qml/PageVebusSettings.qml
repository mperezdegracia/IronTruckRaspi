import QtQuick 1.1
import "utils.js" as Utils

MbPage {
	id: root
	property string bindPrefix

	model: VisualItemModel {
		MbSpinBox {
			description: "AbsorptionVoltage"
			bind: Utils.path(bindPrefix, "/AbsorptionVoltage")
		}

		MbSpinBox {
			description: "FloatVoltage"
			bind: Utils.path(bindPrefix, "/FloatVoltage")
		}

		MbSpinBox {
			description: "ChargeCurrent"
			bind: Utils.path(bindPrefix, "/ChargeCurrent")
		}

		MbSpinBox {
			description: "InverterOutputVoltage"
			bind: Utils.path(bindPrefix, "/InverterOutputVoltage")
		}

		MbSpinBox {
			description: "AcCurrentLimit"
			bind: Utils.path(bindPrefix, "/AcCurrentLimit")
		}

		MbSpinBox {
			description: "RepeatedAbsorptionTime"
			bind: Utils.path(bindPrefix, "/RepeatedAbsorptionTime")
		}

		MbSpinBox {
			description: "RepeatedAbsorptionInterval"
			bind: Utils.path(bindPrefix, "/RepeatedAbsorptionInterval")
		}

		MbSpinBox {
			description: "MaximumAbsorptionTime"
			bind: Utils.path(bindPrefix, "/MaximumAbsorptionTime")
		}

		MbSpinBox {
			description: "ChargeCharacteristic"
			bind: Utils.path(bindPrefix, "/ChargeCharacteristic")
		}
		MbSpinBox {
			description: "InverterDcShutdownVoltage"
			bind: Utils.path(bindPrefix, "/InverterDcShutdownVoltage")
		}

		MbSpinBox {
			description: "InverterDcRestartVoltage"
			bind: Utils.path(bindPrefix, "/InverterDcRestartVoltage")
		}

		MbSpinBox {
			description: "AcLowSwitchInputOff"
			bind: Utils.path(bindPrefix, "/AcLowSwitchInputOff")
		}

		MbSpinBox {
			description: "AcLowSwitchInputOn"
			bind: Utils.path(bindPrefix, "/AcLowSwitchInputOn")
		}

		MbSpinBox {
			description: "AcHighSwitchInputOn"
			bind: Utils.path(bindPrefix, "/AcHighSwitchInputOn")
		}

		MbSpinBox {
			description: "AcHighSwitchInputOff"
			bind: Utils.path(bindPrefix, "/AcHighSwitchInputOff")
		}

		MbSpinBox {
			description: "AssistCurrentBoostFactor"
			bind: Utils.path(bindPrefix, "/AssistCurrentBoostFactor")
		}

		MbSpinBox {
			description: "SecondInputCurrentLimit"
			bind: Utils.path(bindPrefix, "/SecondInputCurrentLimit")
		}

		MbSpinBox {
			description: "LoadForStartingAesMode"
			bind: Utils.path(bindPrefix, "/LoadForStartingAesMode")
		}

		MbSpinBox {
			description: "OffsetForEndingAesMode"
			bind: Utils.path(bindPrefix, "/OffsetForEndingAesMode")
		}

		MbSpinBox {
			description: "LowDcAlarmLevel"
			bind: Utils.path(bindPrefix, "/LowDcAlarmLevel")
		}

		MbSpinBox {
			description: "BatteryCapacity"
			bind: Utils.path(bindPrefix, "/BatteryCapacity")
		}

		MbSpinBox {
			description: "SocWhenBulkfinished"
			bind: Utils.path(bindPrefix, "/SocWhenBulkfinished")
		}

		MbSpinBox {
			description: "FrequencyShiftUBatStart"
			bind: Utils.path(bindPrefix, "/FrequencyShiftUBatStart")
		}

		MbSpinBox {
			description: "FrequencyShiftStartDelay"
			bind: Utils.path(bindPrefix, "/FrequencyShiftStartDelay")
		}

		MbSpinBox {
			description: "FrequencyShiftUBatStop"
			bind: Utils.path(bindPrefix, "/FrequencyShiftUBatStop")
		}

		MbSpinBox {
			description: "FrequencyShiftStopDelay"
			bind: Utils.path(bindPrefix, "/FrequencyShiftStopDelay")
		}
	}
}
