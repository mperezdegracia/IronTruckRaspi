import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage
{
	id: root
	property string bindPrefix: "com.victronenergy.settings"

	model: VisualItemModel {
		MbItemOptions {
			id: accessLevelSelect
			description: qsTr("Access level")
			bind: Utils.path(bindPrefix, "/Settings/System/AccessLevel")
			magicKeys: true
			writeAccessLevel: User.AccessUser
			possibleValues: [
				MbOption { description: qsTr("User"); value: User.AccessUser; password: "ZZZ" },
				MbOption { description: qsTr("User & Installer"); value: User.AccessInstaller; password: "ZZZ" },
				MbOption { description: qsTr("Superuser"); value: User.AccessSuperUser; readonly: true },
				MbOption { description: qsTr("Service"); value: User.AccessService; readonly: true }
			]

			// change to super user mode if the right button is pressed for a while
			property int repeatCount
			onFocusChanged: repeatCount = 0

			function open() {
				if (user.accessLevel >= User.AccessInstaller && ++repeatCount > 60) {
					if (accessLevelSelect.value !== User.AccessSuperUser)
						accessLevelSelect.item.setValue(User.AccessSuperUser)
					repeatCount = 0
				}
			}
		}

		MbEditBox {
			show: user.accessLevel >= User.AccessSuperUser
			description: "Set root password"
			onTextChanged: {
				if (text == "")
					return

				if (text.length < 6) {
					toast.createToast("Please enter at least 6 characters")
				} else {
					toast.createToast(VePlatform.setRootPassword(text))
					text = ""
				}
			}
		}

		MbSwitch {
			name: qsTr("Remote support (SSH)")
			bind: "com.victronenergy.settings/Settings/System/RemoteSupport"
		}

		MbItemValue {
			description: qsTr("Remote support tunnel")
			item.value: remotePort.item.valid && remotePort.item.value !== 0 ? qsTr("Online") : qsTr("Offline")
		}

		MbItemValue {
			id: remotePort
			description: qsTr("Remote support port")
			item.bind: "com.victronenergy.settings/Settings/System/RemoteSupportPort"
		}

		MbOK {
			id: reboot
			description: qsTr("Reboot?")
			writeAccessLevel: User.AccessUser
			onClicked: {
				toast.createToast(qsTr("Rebooting..."), 10000, "icon-restart-active")
				VePlatform.reboot()
			}
		}

		MbSwitch {
			property VBusItem hasBuzzer: VBusItem {bind: "com.victronenergy.system/Buzzer/State"}
			name: qsTr("Audible alarm")
			bind: Utils.path(bindPrefix, "/Settings/Alarm/Audible")
			show: hasBuzzer.valid
		}

		MbSwitch {
			id: demoOnOff
			name: qsTr("Demo mode")
			bind: Utils.path(bindPrefix, "/Settings/Gui/DemoMode")
		}

		MbItemText {
			text: qsTr("Starting demo mode will change some settings and the user interface will be unresponsive for a moment.")
			wrapMode: Text.WordWrap
		}
	}
}
