import QtQuick 1.1

import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	property string uniqueId
	property string bindPrefix: Utils.path("com.victronenergy.settings/Settings/Fronius/Inverters/", uniqueId)

	VBusItem {
		id: phaseItem
		bind: Utils.path(bindPrefix, "/Phase")
	}

	model: VisualItemModel {
		MbItemOptions {
			description: qsTr("Position")
			bind: Utils.path(bindPrefix, "/Position")
			possibleValues: [
				MbOption { description: qsTr("AC Input 1"); value: 0 },
				MbOption { description: qsTr("AC Input 2"); value: 2 },
				MbOption { description: qsTr("AC Output"); value: 1 }
			]
		}

		MbItemValue {
			description: qsTr("Phase")
			show: phaseItem.valid && phaseItem.value === 0
			item.value: "Multiphase"
		}

		MbItemOptions {
			description: qsTr("Phase")
			bind: Utils.path(bindPrefix, "/Phase")
			show: phaseItem.valid && phaseItem.value !== 0
			possibleValues: [
				MbOption {description: qsTr("L1"); value: 1 },
				MbOption {description: qsTr("L2"); value: 2 },
				MbOption {description: qsTr("L3"); value: 3 }
			]
		}

		MbItemOptions {
			description: qsTr("Show")
			bind: Utils.path(bindPrefix, "/IsActive")
			possibleValues:[
				MbOption{description: qsTr("No"); value: 0},
				MbOption{description: qsTr("Yes"); value: 1}
			]
		}
	}
}
