import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	VBusItem {
                id: relay0
                bind: "com.victronenergy.settings/Settings/RpiRelay/0/Name"
        }

	VBusItem {
                id: relay1
                bind: "com.victronenergy.settings/Settings/RpiRelay/1/Name"
        }

	VBusItem {
                id: relay2
                bind: "com.victronenergy.settings/Settings/RpiRelay/2/Name"
        }

	VBusItem {
                id: relay3
                bind: "com.victronenergy.settings/Settings/RpiRelay/3/Name"
        }

	VBusItem {
                id: relay4
                bind: "com.victronenergy.settings/Settings/RpiRelay/4/Name"
        }

	VBusItem {
                id: relay5
                bind: "com.victronenergy.settings/Settings/RpiRelay/5/Name"
        }

	VBusItem {
                id: relay6
                bind: "com.victronenergy.settings/Settings/RpiRelay/6/Name"
        }

	VBusItem {
                id: relay7
                bind: "com.victronenergy.settings/Settings/RpiRelay/7/Name"
        }

	model: VisualItemModel {

		MbSwitch {
			name: relay0.value
			bind: "com.victronenergy.relays/Relay/1/State"
		}
		MbSwitch {
				name: relay1.value
				bind: "com.victronenergy.relays/Relay/2/State"
		}
			
		MbSwitch {
				name: relay2.value  
				bind: "com.victronenergy.relays/Relay/3/State"
		}
			
		MbSwitch {
				name: relay3.value  
				bind: "com.victronenergy.relays/Relay/4/State"
		}
		MbSwitch {
				name: relay4.value  
				bind: "com.victronenergy.relays/Relay/5/State"
		}
		MbSwitch {
				name: relay5.value  
				bind: "com.victronenergy.relays/Relay/6/State"
		}
		MbSwitch {
				name: relay6.value  
				bind: "com.victronenergy.relays/Relay/7/State"
		}
		MbSwitch {
				name: relay7.value  
				bind: "com.victronenergy.relays/Relay/8/State"
		}
		
	

	}

}
