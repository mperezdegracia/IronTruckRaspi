import QtQuick 1.1

import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	title: qsTr("Inverters")
	model: Utils.stringToArray(inverterIdsItem.value)

	property string bindPrefix: "com.victronenergy.settings/Settings/Fronius"

	VBusItem {
		id: inverterIdsItem
		bind: Utils.path(bindPrefix, "/InverterIds")
	}

	function convertPhase(phase)
	{
		if (phase === undefined)
			return '--';
		if (phase === 0)
			return qsTr("MP");
		return "L" + phase;
	}

	function convertPosition(pos)
	{
		switch (pos) {
		case 0:
			return qsTr("In1");
		case 1:
			return qsTr("Out");
		case 2:
			return qsTr("In2");
		default:
			return '--';
		}
	}

	function getDescription(customName, uniqueId)
	{
		if (customName !== undefined && customName.length > 0)
			return customName;
		if (uniqueId !== undefined && uniqueId.length > 1)
			return uniqueId.substring(1)
		return '--'
	}

	delegate: Component {
		MbSubMenu {
			id: menu

			property string uniqueId: modelData
			property string inverterPath: Utils.path(bindPrefix, "/Inverters/", uniqueId)

			// Note: the names of all children of /Settings/Fronius/Inverters
			// start with an 'I', which is not part of the uniqueId of the
			// inverter, so we strip it here.
			description: getDescription(customNameItem.value, uniqueId)
			item.text: qsTr("AC") + "-" + convertPosition(positionItem.value) + " " + convertPhase(phaseItem.value)
			item.textValid: true

			VBusItem {
				id: customNameItem
				bind: Utils.path(inverterPath, "/CustomName")
			}

			VBusItem {
				id: phaseItem
				bind: Utils.path(inverterPath, "/Phase")
			}

			VBusItem {
				id: positionItem
				bind: Utils.path(inverterPath, "/Position")
			}

			subpage: Component {
				PageSettingsFroniusInverter {
					title: menu.description
					uniqueId: menu.uniqueId
				}
			}
		}
	}
}
