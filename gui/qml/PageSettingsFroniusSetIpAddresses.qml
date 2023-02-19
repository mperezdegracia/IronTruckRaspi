import QtQuick 1.1

import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	title: qsTr("IP addresses")
	model: Utils.stringToIpArray(ipAddressesItem.value)

	// Brutally overwrite default key handling
	defaultLeftText: user.accessLevel >= User.AccessInstaller ? qsTr("Add") : ""
	defaultLeftIcon: ""
	defaultRightText: user.accessLevel >= User.AccessInstaller ? qsTr("Remove") : ""
	defaultRightIcon: ""
	Keys.onReturnPressed: removeAddress()
	Keys.onEscapePressed: addAddress()

	property string settingsPrefix: "com.victronenergy.settings"

	function addAddress() {
		if (user.accessLevel < User.AccessInstaller)
			return;
		var addrs = model;
		addrs.push("192.168.001.100");
		var t = addrs.join(',');
		ipAddressesItem.setValue(t);
		currentIndex = addrs.length - 1;
	}

	function removeAddress() {
		if (user.accessLevel < User.AccessInstaller)
			return;
		var addrs = model;
		addrs.splice(currentIndex, 1);
		var t = addrs.join(',');
		if (currentIndex > 0 && currentIndex >= addrs.length)
			--currentIndex;
		ipAddressesItem.setValue(t);
	}

	VBusItem {
		id: ipAddressesItem
		bind: Utils.path(settingsPrefix, "/Settings/Fronius/IPAddresses")
	}

	delegate: Component {
		MbEditBox {
			description: qsTr("IP address") + " " + (index + 1)
			matchString: "0123456789"
			ignoreChars: "."
			text: modelData
			readonly: user.accessLevel < User.AccessInstaller
			onTextChanged: {
				var addrs = Utils.stringToIpArray(ipAddressesItem.value);
				addrs[index] = text;
				ipAddressesItem.setValue(addrs.join(','));
			}
		}
	}
}
