import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	title: qsTr("Services")

	model: VisualItemModel {
		MbSwitch {
			name: qsTr("Modbus/TCP")
			bind: "com.victronenergy.settings/Settings/Services/Modbus"
		}

		MbSwitch {
			id: mqtt
			name: qsTr("MQTT")
			bind: "com.victronenergy.settings/Settings/Services/Mqtt"
		}

		MbSwitch {
			name: qsTr("NMEA2000 on MQTT")
			bind: "com.victronenergy.settings/Settings/Services/MqttN2k"
			show: mqtt.checked && VePlatform.canInterfaces.length > 0
		}

		MbSwitch {
			name: qsTr("VRM two-way communication")
			bind: "com.victronenergy.settings/Settings/Services/Vrmpubnub"
		}

		MbSwitch {
			name: qsTr("Console on VE.Direct 1")
			bind: "com.victronenergy.settings/Settings/Services/Console"
			show: user.accessLevel >= User.AccessSuperUser
		}

		MbItemCanProfile {
			description: qsTr("CAN-bus Profile") + (VePlatform.canInterfaces.length > 1 ? " (1)" : "")
			bind: VePlatform.canInterfaces.length > 0 ? Utils.path("com.victronenergy.settings/Settings/Canbus/",
																   VePlatform.canInterfaces[0], "/Profile") : ""
			show: VePlatform.canInterfaces.length > 0
		}

		MbItemCanProfile {
			description: qsTr("CAN-bus Profile (2)")
			bind: VePlatform.canInterfaces.length > 0 ? Utils.path("com.victronenergy.settings/Settings/Canbus/",
																   VePlatform.canInterfaces[1], "/Profile") : ""
			show: VePlatform.canInterfaces.length > 1
		}
	}
}
