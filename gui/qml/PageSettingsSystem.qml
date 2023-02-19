import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root

	property string bindPrefix: "com.victronenergy.settings"
	property string availableMonitors: availableBatteryServices.valid ? availableBatteryServices.value : ""
	property string autoSelectedMonitorName: autoSelectedBatteryService.valid ? autoSelectedBatteryService.value : "---"

	onAvailableMonitorsChanged: if (availableMonitors !== "") monitorOptions.possibleValues = getMonitorList()

	VBusItem {
		id: availableBatteryServices
		bind: Utils.path("com.victronenergy.system", "/AvailableBatteryServices")
	}

	VBusItem {
		id: autoSelectedBatteryService
		bind: Utils.path("com.victronenergy.system", "/AutoSelectedBatteryService")
	}

	VBusItem {
		id: maxChargeCurrent
		bind: Utils.path("com.victronenergy.settings", "/Settings/SystemSetup/MaxChargeCurrent")
	}

	// As we don't know previously the key names of the json object
	// we need to get the list of keynames and then use it to get
	// the values
	function getMonitorList() {

		var fullList = []
		var jsonObject = JSON.parse(availableMonitors)
		var keylist = Object.keys(jsonObject)
		var component = Qt.createComponent("MbOption.qml");

		for (var i = 0; i < keylist.length; i++) {
			var params = {
				"description": jsonObject[keylist[i]],
				"value": keylist[i]
			}
			var option = component.createObject(monitorOptions, params)
			fullList.push(option)
		}

		return fullList
	}

	model: VisualItemModel {
		// Note: these settings can also be used to add a icon / text to the
		// overview. Mind it that translation of these description can get long.
		// Futhermore there should be a enum defined for this. As it is not used
		// hide the options for now.

		MbItemOptions {
			id: systemName

			property variant defaultNames: ["", "Hub-1", "Hub-2", "Hub-3", "Hub-4", "ESS", qsTr("Vehicle"), qsTr("Boat")]
			property bool customName: defaultNames.indexOf(item.value) < 0

			description: qsTr("System name")
			unknownOptionText: qsTr("User defined")
			bind: Utils.path(bindPrefix, "/Settings/SystemSetup/SystemName")
			writeAccessLevel: User.AccessUser
			possibleValues: [
				MbOption { description: qsTr("Automatic"); value: systemName.defaultNames[0] },
				MbOption { description: systemName.defaultNames[1]; value: systemName.defaultNames[1] },
				MbOption { description: systemName.defaultNames[2]; value: systemName.defaultNames[2] },
				MbOption { description: systemName.defaultNames[3]; value: systemName.defaultNames[3] },
				MbOption { description: systemName.defaultNames[4]; value: systemName.defaultNames[4] },
				MbOption { description: systemName.defaultNames[5]; value: systemName.defaultNames[5] },
				MbOption { description: systemName.defaultNames[6]; value: systemName.defaultNames[6] },
				MbOption { description: systemName.defaultNames[7]; value: systemName.defaultNames[7] },
				MbOption { description: qsTr("User defined"); value: "custom" }
			]
		}

		MbEditBox {

			description: qsTr("User defined name")
			text: systemName.value
			show: systemName.customName
			maximumLength: 20
			bind: Utils.path(bindPrefix, "/Settings/SystemSetup/SystemName")
			writeAccessLevel: User.AccessUser
		}

		// The systemcalc uses these values as well. Not available is defined
		// to the second out of device with a single input can be set to ignored.
		MbItemOptions {
			description: qsTr("AC input 1")
			bind: Utils.path(bindPrefix, "/Settings/SystemSetup/AcInput1")
			possibleValues: [
				MbOption {description: qsTr("Not available"); value: 0},
				MbOption {description: qsTr("Grid"); value: 1},
				MbOption {description: qsTr("Generator"); value: 2},
				MbOption {description: qsTr("Shore power"); value: 3}
			]
		}

		MbItemOptions {
			description: qsTr("AC input 2")
			bind: Utils.path(bindPrefix, "/Settings/SystemSetup/AcInput2")
			possibleValues: [
				MbOption {description: qsTr("Not available"); value: 0},
				MbOption {description: qsTr("Grid"); value: 1},
				MbOption {description: qsTr("Generator"); value: 2},
				MbOption {description: qsTr("Shore power"); value: 3}
			]
		}

		MbItemOptions {
			id: monitorOptions
			description: qsTr("Battery monitor")
			bind: Utils.path("com.victronenergy.settings", "/Settings/SystemSetup/BatteryService")
			unknownOptionText: qsTr("Unavailable monitor, set another")
		}

		MbItemText {
			text: qsTr("Auto selected: %1").arg(autoSelectedMonitorName)
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignLeft
			show: monitorOptions.value === "default"
		}

		MbItemOptions {
			description: qsTr("Synchronize VE.Bus SOC with battery")
			bind: "com.victronenergy.system/Control/VebusSoc"
			readonly: true
			possibleValues: [
				MbOption { description: qsTr("Off"); value: 0 },
				MbOption { description: qsTr("On"); value: 1 }
			]
		}

		MbItemOptions {
			description: qsTr("Use solar charger current to improve VE.Bus SOC")
			bind: "com.victronenergy.system/Control/ExtraBatteryCurrent"
			readonly: true
			possibleValues: [
				MbOption { description: qsTr("Off"); value: 0 },
				MbOption { description: qsTr("On"); value: 1 }
			]
		}

		MbItemOptions {
			description: qsTr("Solar charger voltage control")
			bind: "com.victronenergy.system/Control/SolarChargeVoltage"
			readonly: true
			possibleValues: [
				MbOption { description: qsTr("Off"); value: 0 },
				MbOption { description: qsTr("On"); value: 1 }
			]
		}

		MbItemOptions {
			description: qsTr("Solar charger current control")
			bind: "com.victronenergy.system/Control/SolarChargeCurrent"
			readonly: true
			possibleValues: [
				MbOption { description: qsTr("Off"); value: 0 },
				MbOption { description: qsTr("On"); value: 1 }
			]
		}

		MbSwitch {
			bind: Utils.path(bindPrefix, "/Settings/SystemSetup/HasDcSystem")
			name: qsTr("Has DC system")
		}

		MbItemText {
			text: qsTr("Distributed voltage and current control (DVCC) requires minimum VE.Bus firmware version 422 and VE.Direct solar charger firmware version v1.29. " +
				"VE.Can connected solar chargers are not supported.\n\n" +
				"Read the manual before enabling this feature.")
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignLeft
		}

		MbSwitch {
			id: bolSwitch
			name: qsTr("DVCC")
			bind: Utils.path(bindPrefix, "/Settings/Services/Bol")
			show: user.accessLevel >= User.AccessInstaller
		}

		MbSwitch {
			name: qsTr("SVS - Shared voltage sense")
			bind: Utils.path(bindPrefix, "/Settings/SystemSetup/SharedVoltageSense")
			show: bolSwitch.show && bolSwitch.checked
		}

		MbSwitch {
			VBusItem {
				id: maxChargeCurrentControl
				bind: Utils.path("com.victronenergy.system", "/Control/MaxChargeCurrent")
			}

			function edit() {
				maxChargeCurrent.setValue(maxChargeCurrent.value < 0 ? 50 : -1)
			}

			id: maxChargeCurrentSwitch
			name: qsTr("Limit charge current")
			checked: maxChargeCurrent.value >= 0
			enabled: userHasWriteAccess
			show: maxChargeCurrentControl.valid && maxChargeCurrentControl.value && bolSwitch.show && bolSwitch.checked
		}

		MbSpinBox {
			id: startValue
			description: "Maximum charge current"
			bind: maxChargeCurrent.bind
			unit: "A"
			numOfDecimals: 0
			stepSize: 1
			min: 0
			show: maxChargeCurrentSwitch.show && maxChargeCurrentSwitch.checked
		}


		MbItemOptions {
			description: qsTr("BMS control")
			bind: "com.victronenergy.system/Control/BmsParameters"
			show: bolSwitch.show && bolSwitch.checked
			readonly: true
			possibleValues: [
				MbOption { description: qsTr("Off"); value: 0 },
				MbOption { description: qsTr("On"); value: 1 }
			]
		}

	}
}
