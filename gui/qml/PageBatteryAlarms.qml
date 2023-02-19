import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	property string bindPrefix

	property VBusItem clearStatusRegisterFlags: VBusItem { bind: service.path("/ClearStatusRegisterFlags") }

	MbItemText {
		text: qsTr("No alarms")
		show: _visibleCount === 0
		style.isCurrentItem: true
	}

	model: VisualItemModel {
		id: alarms

		MbItemAlarm {
			description: qsTr("Low battery voltage")
			bind: Utils.path(bindPrefix, "/Alarms/LowVoltage")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("High battery voltage")
			bind: Utils.path(bindPrefix, "/Alarms/HighVoltage")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("High charge current")
			bind: Utils.path(bindPrefix, "/Alarms/HighChargeCurrent")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("High discharge current")
			bind: Utils.path(bindPrefix, "/Alarms/HighDischargeCurrent")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Low SOC")
			bind: Utils.path(bindPrefix, "/Alarms/LowSoc")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("State of health")
			bind: Utils.path(bindPrefix, "/Alarms/StateOfHealth")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Low starter voltage")
			bind: Utils.path(bindPrefix, "/Alarms/LowStarterVoltage")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("High starter voltage")
			bind: Utils.path(bindPrefix, "/Alarms/HighStarterVoltage")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Low temperature")
			bind: Utils.path(bindPrefix, "/Alarms/LowTemperature")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("High temperature")
			bind: Utils.path(bindPrefix, "/Alarms/HighTemperature")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Battery temperature sensor")
			bind: Utils.path(bindPrefix, "/Alarms/BatteryTemperatureSensor")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Mid-point voltage")
			bind: Utils.path(bindPrefix, "/Alarms/MidVoltage")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Fuse blown")
			bind: Utils.path(bindPrefix, "/Alarms/FuseBlown")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("High internal temperature")
			bind: Utils.path(bindPrefix, "/Alarms/HighInternalTemperature")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Low charge temperature")
			bind: Utils.path(bindPrefix, "/Alarms/LowChargeTemperature")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("High charge temperature")
			bind: Utils.path(bindPrefix, "/Alarms/HighChargeTemperature")
			show: valid
		}

		// note: normally split in Charge/Discharge, but the redflow battery does not have such a distinction
		MbItemAlarm {
			description: qsTr("Over current")
			bind: Utils.path(bindPrefix, "/Alarms/OverCurrent")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Air temperature sensor")
			bind: Utils.path(bindPrefix, "/Alarms/AirTemperatureSensor")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Zinc pump")
			bind: Utils.path(bindPrefix, "/Alarms/ZincPump")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Bromide pump")
			bind: Utils.path(bindPrefix, "/Alarms/BromidePump")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Leak sensors")
			bind: Utils.path(bindPrefix, "/Alarms/LeakSensors")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Internal failure")
			bind: Utils.path(bindPrefix, "/Alarms/InternalFailure")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Electric board")
			bind: Utils.path(bindPrefix, "/Alarms/ElectricBoard")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Leak 1 trip")
			bind: Utils.path(bindPrefix, "/Alarms/Leak1Trip")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Leak 2 trip")
			bind: Utils.path(bindPrefix, "/Alarms/Leak2Trip")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Circuit breaker tripped")
			bind: "com.victronenergy.system/Dc/Battery/Alarms/CircuitBreakerTripped"
			show: valid
		}

		MbItemAlarm {
			description: "Unknown" // I need a better description
			bind: Utils.path(bindPrefix, "/Alarms/Unknown")
			show: valid
		}

		MbItemAlarm {
			description: qsTr("Cell imbalance")
			bind: Utils.path(bindPrefix, "/Alarms/CellImbalance")
			show: valid
		}

		MbOK {
			description: qsTr("Clear alarm status")
			value: clearStatusRegisterFlags.value === 0 ? qsTr("Press to clear") : qsTr("Clearing")
			cornerMark: false
			editable: userHasWriteAccess && clearStatusRegisterFlags.value === 0
			writeAccessLevel: User.AccessUser
			show: clearStatusRegisterFlags.valid
			onClicked: clearStatusRegisterFlags.setValue(1)
		}
	}
}
