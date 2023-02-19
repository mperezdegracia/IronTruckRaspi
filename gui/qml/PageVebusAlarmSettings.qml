import QtQuick 1.1
import "utils.js" as Utils

MbPage {
	property string bindPrefix: "com.victronenergy.settings"

	model: VisualItemModel {
		MbItemAlarmEnableLevel {
			description: qsTr("Low battery")
			bind: Utils.path(bindPrefix, "/Settings/Alarm/Vebus/LowBattery")
		}

		MbItemAlarmEnableLevel {
			description: qsTr("High temperature")
			bind: Utils.path(bindPrefix, "/Settings/Alarm/Vebus/HighTemperature")
		}

		MbItemAlarmEnableLevel {
			description: qsTr("Inverter Overload")
			bind: Utils.path(bindPrefix, "/Settings/Alarm/Vebus/InverterOverload")
		}

		MbItemAlarmEnableLevel {
			description: qsTr("High DC ripple")
			bind: Utils.path(bindPrefix, "/Settings/Alarm/Vebus/HighDcRipple")
		}

		MbItemAlarmEnableLevel {
			description: qsTr("Temperature sense error")
			bind: Utils.path(bindPrefix, "/Settings/Alarm/Vebus/TemperatureSenseError")
		}

		MbItemAlarmEnableLevel {
			description: qsTr("Voltage sense error")
			bind: Utils.path(bindPrefix, "/Settings/Alarm/Vebus/VoltageSenseError")
		}

		MbItemOptions {
			description: qsTr("VE.Bus error")
			bind: Utils.path(bindPrefix, "/Settings/Alarm/Vebus/VeBusError")
			possibleValues:[
				MbOption{description: qsTr("Disabled"); value: 0},
				MbOption{description: qsTr("Enabled"); value: 2}
			]
		}
	}
}
