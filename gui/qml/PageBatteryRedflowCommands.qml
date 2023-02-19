import QtQuick 1.1
import com.victron.velib 1.0

MbPage {
	id: root
	property variant service

	property VBusItem requestDelayedSelfMaintenance: VBusItem { bind: service.path("/RequestDelayedSelfMaintenance") }
	property VBusItem requestImmediateSelfMaintenance: VBusItem { bind: service.path("/RequestImmediateSelfMaintenance") }
	property VBusItem maintenanceNeeded: VBusItem { bind: service.path("/Alarms/MaintenanceNeeded") }
	property VBusItem maintenanceActive: VBusItem { bind: service.path("/Alarms/MaintenanceActive") }
	property VBusItem deviceAddresses: VBusItem { bind: "com.victronenergy.battery.zbm/DeviceAddresses" }

	VBusItem {
		id: deviceAddress
		bind: service.path("/DeviceAddress")
		onValueChanged: {
			if (value !== undefined) {
				var s = '000' + value
				addressEdit.text = s.substring(s.length - 3)
			}
		}
	}

	function formatDeviceAddresses(v)
	{
		if (v === undefined)
			return;
		var addresses = v.split(',')
		addresses.sort()
		return addresses.join(', ')
	}

	model: VisualItemModel {
		MbItemValue {
			description: qsTr("Modbus addresses in use")
			item.value: formatDeviceAddresses(deviceAddresses.value)
			show: deviceAddress.valid
		}

		MbEditBox {
			id: addressEdit
			description: qsTr("Modbus address")
			matchString: "0123456789"
			readonly: user.accessLevel < User.AccessInstaller
			onTextChanged: {
				var addresses = deviceAddresses.value.split(',')
				if (addresses.indexOf(text) === -1) {
					var a = parseInt(text)
					if (a > 1 && a < 255 && a !== 99) {
						deviceAddress.setValue(a)
						return
					}
				}
				text = deviceAddress.value.toString();
				toast.createToast(qsTr("Cannot use this address"));
			}
			show: deviceAddress.valid
		}

		MbOK {
			description: qsTr("Maintenance at end of discharge")
			value: maintenanceNeeded.value === 0 ? qsTr("Press to schedule") : qsTr("Scheduled")
			editable: userHasWriteAccess && requestDelayedSelfMaintenance.value === 0 && maintenanceActive.value === 0
			cornerMark: false
			writeAccessLevel: User.AccessUser
			onClicked: requestDelayedSelfMaintenance.setValue(1)
		}

		MbItemOptions {
			description: qsTr("Enter run command")
			bind: service.path("/OperationalMode")
			writeAccessLevel: User.AccessUser
			possibleValues: [
				MbOption { description: qsTr("Select"); value: -1; readonly: true },
				MbOption { description: qsTr("Off"); value: 0; readonly: true },
				MbOption { description: qsTr("Offline/float"); value: 1 },
				MbOption { description: qsTr("Run"); value: 2 },
				MbOption { description: qsTr("Hibernation"); value: 3 }
			]
		}

		MbOK {
			description: qsTr("Self discharge and maintenance cycle")
			value: maintenanceActive.value === 0 ? qsTr("Press to start") : qsTr("Started")
			editable: userHasWriteAccess && requestImmediateSelfMaintenance.value === 0 && maintenanceActive.value === 0
			cornerMark: false
			writeAccessLevel: User.AccessUser
			onClicked: requestImmediateSelfMaintenance.setValue(1)
		}
	}
}
