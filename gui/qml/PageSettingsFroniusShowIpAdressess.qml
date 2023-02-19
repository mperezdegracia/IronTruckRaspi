import QtQuick 1.1

import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	title: qsTr("Detected IP addresses")
	model:  Utils.stringToIpArray(ipAddressesItem.value)

	property string settingsPrefix: "com.victronenergy.settings"

	VBusItem {
		id: ipAddressesItem
		bind: Utils.path(settingsPrefix, "/Settings/Fronius/KnownIPAddresses")
	}

	delegate: Component {
		MbItemValue {
			description: qsTr("IP address") + " " + (index + 1)
			item.value: modelData
		}
	}
}
