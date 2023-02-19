import QtQuick 1.1

// Profiles for canbus
MbItemOptions {
	possibleValues: [
		MbOption { description: qsTr("Disabled"); value: 0 },
		MbOption { description: qsTr("VE.Can & Lynx Ion BMS (250 kbit/s)"); value: 1 },
		MbOption { description: qsTr("VE.Can & CAN-bus BMS (250 kbit/s)"); value: 2 },
		MbOption { description: qsTr("CAN-bus BMS (500 kbit/s)"); value: 3 },
		MbOption { description: qsTr("Oceanvolt (250 kbit/s)"); value: 4 }
	]
}
