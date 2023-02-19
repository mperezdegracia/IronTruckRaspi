import QtQuick 1.1
import com.victron.velib 1.0

MbPage {
	VBusItem {
		id: redetectSystem
		bind: service.path("/RedetectSystem")
	}
	VBusItem {
		id: systemReset
		bind: service.path("/SystemReset")
	}

	model: VisualItemModel {
		MbOK {
			description: qsTr("Redetect System")
			value: redetectSystem.value === 1 ? qsTr("Redetecting...") : qsTr("Press to redetect")
			editable: redetectSystem.valid
			cornerMark: redetectSystem.value === 0
			writeAccessLevel: User.AccessUser
			onClicked: redetectSystem.setValue(1)
		}

		MbOK {
			description: qsTr("System reset")
			value: systemReset.value === 1 ? qsTr("Resetting...") : qsTr("Press to reset")
			editable: systemReset.valid
			cornerMark: systemReset.value === 0
			writeAccessLevel: User.AccessUser
			onClicked: systemReset.setValue(1)
		}

		MbSubMenu {
			id: submenu
			description: qsTr("Alarms")
			subpage: Component {
				PageVebusAlarmSettings {
					title: submenu.description
				}
			}
		}
	}
}
