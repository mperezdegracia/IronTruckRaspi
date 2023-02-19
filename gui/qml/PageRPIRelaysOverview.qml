import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	model: VisualItemModel {
		MbSwitch {
			name: qsTr("Relay 1")
			bind: "com.victronenergy.relays/Relay/1/State"
		}
		MbSwitch {
				name: qsTr("Relay 2")
				bind: "com.victronenergy.relays/Relay/2/State"
		}
			
		MbSwitch {
				name: qsTr("Relay 3")
				bind: "com.victronenergy.relays/Relay/3/State"
		}
			
		MbSwitch {
				name: qsTr("Relay 4")
				bind: "com.victronenergy.relays/Relay/4/State"
		}
		MbSwitch {
				name: qsTr("Relay 5")
				bind: "com.victronenergy.relays/Relay/5/State"
		}
		MbSwitch {
				name: qsTr("Relay 6")
				bind: "com.victronenergy.relays/Relay/6/State"
		}
		MbSwitch {
				name: qsTr("Relay 7")
				bind: "com.victronenergy.relays/Relay/7/State"
		}
		MbSwitch {
				name: qsTr("Relay 8")
				bind: "com.victronenergy.relays/Relay/8/State"
		}
		
	

	}

}
