import QtQuick 1.1
import Qt.labs.components.native 1.0
import net.connman 0.1

MbPage {
	id: root
	title: qsTr("Wi-Fi")
	property bool serviceListUpdate: false
	property CmTechnology tech: Connman.getTechnology("wifi")
	model: Connman.getServiceList("wifi")

	Connections {
		target: Connman
		onServiceListChanged: {
			if (root.status == PageStatus.Active)
				model = Connman.getServiceList("wifi")
			else
				serviceListUpdate = true
		}
	}

	Timer {
			interval: 10000
			running: root.status == PageStatus.Active
			repeat: true
			triggeredOnStart: true
			onTriggered: {
				if (tech)
					tech.scan()
			}
	}

	FnCmStates {
		id: cmState
	}

	onStatusChanged: {
		if (root.status == PageStatus.Active && serviceListUpdate) {
			model = Connman.getServiceList("wifi")
			serviceListUpdate = false
		}
	}

	delegate: MbSubMenu {
		id: wifiPoint
		property CmService service: Connman.getService(modelData)

		description: service.name
		check: service.favorite
		indent: true
		item.text: cmState.getState(service.state, true)
		subpage: Component {
			PageSettingsTcpIp {
				title: wifiPoint.service.name
				path: modelData
				service: wifiPoint.service
				technologyType: "wifi"
			}
		}
	}

	MbItemText {
		visible: model.length === 0
		text: noModelDescription()
		style: MbStyle {
			isCurrentItem: true
		}
	}

	function noModelDescription() {
		if (tech) {
			if (tech.powered)
				return qsTr("No access points")
			else {
				tech.powered = true;
				return qsTr("No Wi-Fi adapter connected")
			}
		} else {
			return qsTr("No Wi-Fi adapter connected")
		}
	}
}
