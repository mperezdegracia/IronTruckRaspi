import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: pageRelaySettings
	title: qsTr("Relay")
	property string bindPrefix: "com.victronenergy.settings"

	model: VisualItemModel {
		MbItemOptions {
			id: relayFunction
			description: qsTr("Function")
			bind: Utils.path(bindPrefix, "/Settings/Relay/Function")
			possibleValues:[
				MbOption { description: qsTr("Alarm relay"); value: 0 },
				MbOption { description: qsTr("Generator start/stop"); value: 1 },
				MbOption { description: qsTr("Tank pump"); value: 3 },
				MbOption { description: qsTr("Manual"); value: 2 }
			]
		}

		MbItemOptions {
			description: qsTr("Alarm relay polarity")
			bind: Utils.path(bindPrefix, "/Settings/Relay/Polarity")
			show: relayFunction.value === 0
			possibleValues: [
				MbOption { description: qsTr("Normally open"); value: 0 },
				MbOption { description: qsTr("Normally closed"); value: 1 }
			]
		}

		MbSwitch {
			id: relaySwitch
			// Use a one-way binding, because the usual binding:
			// checked: Relay.relayOn
			// will be broken when the switched toggled, and changes in the relayOn property made
			// elsewhere will not change the state of the switch any more.
			Binding {
				target: relaySwitch
				property: "checked"
				value: Relay.relayOn
				when: true
			}
			enabled: userHasWriteAccess
			name: qsTr("Alarm relay On")
			onCheckedChanged: Relay.relayOn = checked;
			show: relayFunction.value === 0
		}

		MbSwitch {
			id: manualSwitch
			name: qsTr("Relay On")
			bind: "com.victronenergy.system/Relay/0/State"
			show: relayFunction.value === 2 // manual mode
		}
	}
}
