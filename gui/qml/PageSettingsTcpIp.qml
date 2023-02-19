import QtQuick 1.1
import Qt.labs.components.native 1.0
import net.connman 0.1
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Ethernet")
	property string technologyType: "ethernet"
	property string path: Connman.getServiceList(technologyType)[0]
	property CmService service: Connman.getService(path)
	property string security: service.security.toString()
	property bool secured: security.indexOf("none") === -1 && security !== ""
	property string serviceMethod: service.ipv4["Method"] ? service.ipv4["Method"] : "--"
	property bool readonlySettings: true
	property bool wifi: technologyType === "wifi"
	property string agentPath: "/com/victronenergy/ccgx"
	property CmAgent agent;
	property string passphrase: ""

	Connections {
		target: service
		onPropertyChangeFailed: {
			restoreText("All")
		}
		onIpv4Changed: {
			if (service.ipv4["Address"])
				ipaddress.text = service.formatIpAddress(service.ipv4["Address"]);
			if (service.ipv4["Netmask"])
				netmask.text = service.formatIpAddress(service.ipv4["Netmask"]);
			if (service.ipv4["Gateway"])
				gateway.text = service.formatIpAddress(service.ipv4["Gateway"]);
		}
		onNameserversChanged: {
			nameserver.text = service.formatIpAddress(service.nameservers[0])
		}
	}

	Connections {
		target: Connman
		onServiceRemoved: {
			if ( path == root.path && root.visible )
				root.model = unplugged
		}
		onServiceAdded: {
			if ( path == root.path && root.visible && !service) {
				service = Connman.getService(path)
				root.model = serviceItems
			}
		}
	}

	FnCmStates {
		id: cmState
	}

	model: service ?  serviceItems : unplugged
	VisualItemModel {
		id: unplugged

		MbItemValue {
			description: qsTr("State")
			item.value: wifi ? qsTr("Connection lost") : qsTr("Unplugged")
		}
	}

	VisualItemModel {
		id: serviceItems

		MbItemValue {
			description: qsTr("State")
			item.value: cmState.getState(service.state, wifi)
		}

		MbItemValue {
			description: qsTr("Name")
			item.value: service.name
			show: wifi
		}

		MbEditBox {
			id: passwordInput
			description: qsTr("Password")
			text: passphrase
			maximumLength: 35
			onTextChanged: {
				sendPassword(text)
				listview.currentIndex = 1;
			}
			show: (wifi && (service.state === "idle" || service.state === "failure") && !service.favorite && secured)
			writeAccessLevel: User.AccessUser
		}

		MbOK {
			id: connect
			description: qsTr("Connect to network?")
			onClicked: {
				service.connect();
				listview.currentIndex = 1;
			}
			show: (wifi && (service.state === "idle" || service.state === "failure") && (service.favorite || !secured))
			writeAccessLevel: User.AccessUser
		}

		MbOK {
			id: forget
			description: qsTr("Forget network?")
			onClicked: {
				service.remove();
				listview.currentIndex = 1;
			}
			show: wifi && service.favorite
			writeAccessLevel: User.AccessUser
		}

		MbItemValue {
			description: qsTr("Signal strength")
			item.value: service.strength+" %"
			show: wifi
		}

		MbItemValue {
			description: qsTr("MAC address")
			item.value: service.ethernet["Address"]
		}

		MbItemOptions {
			id: method
			description: qsTr("IP configuration")
			localValue: serviceMethod
			writeAccessLevel: User.AccessUser
			possibleValues: [
				MbOption{description: qsTr("Automatic"); value: "dhcp"},
				MbOption{description: qsTr("Manual"); value: "manual"},
				MbOption{description: qsTr("Off"); value: "off"; readonly: true},
				MbOption{description: qsTr("Fixed"); value: "fixed"; readonly: true}
			]
			onValueChanged: {
				setMethod(value)
			}
		}

		MbEditBox {
			id: ipaddress
			description: qsTr("IP address")
			readonly: readonlySettings || !method.userHasWriteAccess
			writeAccessLevel: User.AccessUser
			matchString: "0123456789"
			ignoreChars: "."
			text: service.formatIpAddress(service.ipv4["Address"])
			onTextChanged:  setIpv4Property("Address",text)
		}

		MbEditBox {
			id: netmask
			description: qsTr("Netmask")
			readonly: readonlySettings || !method.userHasWriteAccess
			writeAccessLevel: User.AccessUser
			matchString: "0123456789"
			ignoreChars: "."
			text: service.formatIpAddress(service.ipv4["Netmask"])
			onTextChanged:  setIpv4Property("Netmask",text)
		}

		MbEditBox {
			id: gateway
			description: qsTr("Gateway")
			readonly: readonlySettings || !method.userHasWriteAccess
			writeAccessLevel: User.AccessUser
			matchString: "0123456789"
			ignoreChars: "."
			text: service.formatIpAddress(service.ipv4["Gateway"])
			onTextChanged: setIpv4Property("Gateway",text)
		}

		MbEditBox {
			id: nameserver
			description: qsTr("DNS server")
			readonly: readonlySettings || !method.userHasWriteAccess
			writeAccessLevel: User.AccessUser
			matchString: "0123456789"
			ignoreChars: "."
			text: service.formatIpAddress(service.nameservers[0])
			onTextChanged: setNamerserversProperty(text)
		}
	}

	Component.onCompleted: {
		if (wifi)
			agent = Connman.registerAgent(agentPath)
	}

	Component.onDestruction: {
		if (wifi)
			Connman.unRegisterAgent(agentPath)
	}

	function sendPassword(password) {
		if (wifi) {
			agent.passphrase = password
			service.connect()
		}
	}

	function setIpv4Property(name, value) {
		var ipv4Config = service.ipv4
		if (ipv4Config[name] !== value) {
			var addr = service.checkIpAddress(value)
			if (addr === "invalid") {
				restoreText(name)
			} else {
				ipv4Config[name] = addr
				service.ipv4Config = ipv4Config
			}
		}
	}

	function setNamerserversProperty(value) {
		var nameserversConfig = service.nameservers
		if (nameserversConfig !== value) {
			var addr = service.checkIpAddress(value)
			if (addr === "invalid") {
				restoreText("Nameserver")
			} else {
				nameserversConfig = addr
				service.nameserversConfig = nameserversConfig
			}
		}
	}

	function setMethod(selectedMethod) {
		if (!service)
			return

		var ipv4Config = service.ipv4
		var nameserversConfig = service.nameservers
		var oldMethod = ipv4Config["Method"]

		switch (selectedMethod) {
		case "dhcp":
			readonlySettings = true
			if (oldMethod === "manual") {
				ipv4Config['Address'] = "255.255.255.255"
				service.ipv4Config = ipv4Config
			}
			ipv4Config["Method"] = "dhcp"
			nameserversConfig = []
			break
		case "manual":
			readonlySettings = false
			ipv4Config["Method"] = "manual"
			var addr = service.checkIpAddress(ipv4Config["Address"])
			/*
			 * Make sure the ip settings are valid when switching to "manual"
			 * When the ip settings are not valid, connman will continuously disconnect
			 * and reconnect the service and it is impossible to set the ip-address.
			 */
			if (addr === "invalid") {
				ipv4Config["Address"] = "169.254.1.2"
				ipv4Config["Netmask"] = "255.255.255.0"
				ipv4Config["Gateway"] = "169.254.1.1"
			}
			break
		default:
			readonlySettings = true
			break;
		}
		if (ipv4Config["Method"] !== oldMethod) {
			service.ipv4Config = ipv4Config
			service.nameserversConfig = nameserversConfig
		}
	}

	function restoreText(name) {
		switch(name) {
		case "Address":
			ipaddress.restoreOriginalText();
			break;
		case "Netmask":
			netmask.restoreOriginalText()
			break;
		case "Gateway":
			gateway.restoreOriginalText()
			break;
		case "Nameserver":
			nameserver.restoreOriginalText()
			break;
		default:
			ipaddress.restoreOriginalText()
			netmask.restoreOriginalText()
			gateway.restoreOriginalText()
			nameserver.restoreOriginalText()
			break;
		}
	}
}
