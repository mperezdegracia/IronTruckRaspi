import QtQuick 1.1
import "utils.js" as Utils

MbPage {
	id: root
	property string bindPrefix
	property int numberOfPhases: phases.valid ? phases.value : 1

	VBusItem {
		id: phases
		bind: Utils.path(bindPrefix, "/Ac/NumberOfPhases")
	}

	model: VisualItemModel {
		MbItemValue {
			description: qsTr("VE.Bus Error")
			item.bind: Utils.path(bindPrefix, "/VebusError")
		}

		MbItemVebusAlarm {
			description: qsTr("Low battery")
			bindPrefix: root.bindPrefix
			numOfPhases: root.numberOfPhases
			alarm: "LowBattery"
		}

		MbItemVebusAlarm {
			description: qsTr("Temperature")
			bindPrefix: root.bindPrefix
			numOfPhases: root.numberOfPhases
			alarm: "HighTemperature"
		}

		MbItemVebusAlarm {
			description: qsTr("Overload")
			bindPrefix: root.bindPrefix
			numOfPhases: root.numberOfPhases
			alarm: "Overload"
		}

		MbItemVebusAlarm {
			description: qsTr("DC ripple")
			bindPrefix: root.bindPrefix
			numOfPhases: root.numberOfPhases
			alarm: "Ripple"
		}

		MbItemVebusAlarm {
			description: qsTr("Voltage Sensor")
			bindPrefix: root.bindPrefix
			alarm: "VoltageSensor"
			errorItem: true
			multiPhase: false
		}

		MbItemVebusAlarm {
			description: qsTr("Temperature Sensor")
			bindPrefix: root.bindPrefix
			alarm: "TemperatureSensor"
			errorItem: true
			multiPhase: false
		}
	}
}
