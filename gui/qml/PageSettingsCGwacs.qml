import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	property string devicePath
	property bool multiPhaseSupport: deviceTypeItem.valid && (
										 deviceTypeItem.value >= 71 &&
										 deviceTypeItem.value <= 73) || (
										 deviceTypeItem.value >= 340 &&
										 deviceTypeItem.value <= 346)
	property int hub4PhaseCompensation: 1
	property int hub4PhaseSplit: 2
	property bool initialized: false

	Component.onCompleted: initialized = true

	VBusItem {
		// This value is used to construct the device service name on the D-Bus
		// either 'grid', 'pvinverter' or 'genset'
		id: serviceTypeItem
		bind: Utils.path(devicePath, "/ServiceType")
	}

	VBusItem {
		// Device type of grid meter as taken from grid meter. Values are
		// defined by Carlo Gavazzi.
		id: deviceTypeItem
		bind: Utils.path(devicePath, "/DeviceType")
	}

	VBusItem {
		id: isMultiPhaseItem
		bind: Utils.path(devicePath, "/IsMultiPhase")
	}

	VBusItem {
		id: l2serviceType
		bind: Utils.path(devicePath, "/L2/ServiceType")
	}

	model: VisualItemModel {
		MbItemOptions {
			id: mode
			description: qsTr("Role")
			bind: Utils.path(devicePath, "/ServiceType")
			possibleValues: [
				MbOption { description: qsTr("Grid meter"); value: "grid" },
				MbOption { description: qsTr("PV inverter"); value: "pvinverter" },
				MbOption { description: qsTr("Generator"); value: "genset" }
			]
		}

		MbItemOptions {
			description: qsTr("Position")
			bind: Utils.path(devicePath, "/Position")
			show: serviceTypeItem.value === "pvinverter"
			possibleValues: [
				MbOption { description: qsTr("AC Input 1"); value: 0 },
				MbOption { description: qsTr("AC Input 2"); value: 2 },
				MbOption { description: qsTr("AC Output"); value: 1 }
			]
		}

		MbItemOptions {
			description: qsTr("Phase type")
			bind: Utils.path(devicePath, "/IsMultiPhase")
			readonly: !userHasWriteAccess || !multiPhaseSupport
			possibleValues: [
				MbOption { description: qsTr("Single phase"); value: 0 },
				MbOption { description: qsTr("Multi phase"); value: 1 }
			]
		}

		MbSpinBox {
			id: modbusAddress
			description: qsTr("Modbus unit ID")
			bind: Utils.path(devicePath, "/DeviceInstance")
			min: 30
			max: 39
			stepSize: 1
			numOfDecimals: 0
			enabled: userHasWriteAccess
		}

		MbSwitch {
			name: qsTr("PV inverter on phase 2")
			valueTrue: "pvinverter"
			valueFalse: ""
			bind: Utils.path(devicePath, "/L2/ServiceType")
			show: multiPhaseSupport &&
				  isMultiPhaseItem.valid &&
				  !isMultiPhaseItem.value &&
				  serviceTypeItem.value === "grid"
		}

		MbItemOptions {
			description: qsTr("PV inverter on phase 2 Position")
			bind: Utils.path(devicePath, "/L2/Position")
			show: l2serviceType.value === "pvinverter"
			possibleValues: [
				MbOption { description: qsTr("AC Input 1"); value: 0 },
				MbOption { description: qsTr("AC Input 2"); value: 2 },
				MbOption { description: qsTr("AC Output"); value: 1 }
			]
		}

		MbSpinBox {
			id: l2ModbusAddress
			description: qsTr("PV inverter on phase 2 Modbus address")
			bind: Utils.path(devicePath, "/L2/DeviceInstance")
			min: 30
			max: 39
			stepSize: 1
			numOfDecimals: 0
			enabled: userHasWriteAccess
			show: l2serviceType.value === "pvinverter"
		}
	}
}
