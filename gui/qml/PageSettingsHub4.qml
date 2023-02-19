import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	property string cgwacsPath: "com.victronenergy.settings/Settings/CGwacs"
	property string settingsPrefix: "com.victronenergy.settings"
	property string batteryLifePath: cgwacsPath + "/BatteryLife"
	// Hub4Mode
	property int hub4PhaseCompensation: 1
	property int hub4PhaseSplit: 2
	property int hub4Disabled: 3
	// BatteryLifeState
	property int batteryLifeStateDisabled: 0
	property int batteryLifeStateRestart: 1
	property int batteryLifeStateDefault: 2
	property int batteryLifeStateAbsorption: 3
	property int batteryLifeStateFloat: 4
	property int batteryLifeStateDischarged: 5
	property int batteryLifeStateForceCharge: 6
	property int batteryLifeStateSustain: 7
	property int batteryLifeStateLowSocCharge: 8
	property int batteryKeepCharged: 9
	property int batterySocGuardDefault: 10
	property int batterySocGuardDischarged: 11
	property int batterySocGuardLowSocCharge: 12

	property bool initialized: false

	title: systemType.value === "Hub-4" ? systemType.value : qsTr("ESS")

	Component.onCompleted: {
		initialized = true
	}

	VBusItem {
		id: systemType
		bind: "com.victronenergy.system/SystemType"
	}

	VBusItem {
		id: gridSetpoint
		bind: "com.victronenergy.settings/Settings/CGwacs/AcPowerSetPoint"
	}

	VBusItem {
		id: maxChargePowerItem
		bind: Utils.path(cgwacsPath, "/MaxChargePower")
	}

	VBusItem {
		id: maxDischargePowerItem
		bind: Utils.path(cgwacsPath, "/MaxDischargePower")
	}

	VBusItem {
		id: socLimitItem
		bind: Utils.path(batteryLifePath, "/SocLimit")
	}

	VBusItem {
		id: minSocLimitItem
		bind: Utils.path(batteryLifePath, "/MinimumSocLimit")
	}

	VBusItem {
		id: stateItem
		bind: Utils.path(batteryLifePath, "/State")
	}

	VBusItem {
		id: hub4Mode
		bind: Utils.path(cgwacsPath, "/Hub4Mode")
	}

	VBusItem {
		id: maxChargeCurrentControl
		bind: Utils.path("com.victronenergy.system", "/Control/MaxChargeCurrent")
	}

	model: systemType.value === "ESS" || systemType.value === "Hub-4" ? hub4Settings : noHub4

	VisualItemModel {
		id: noHub4

		MbItemText {
			text: qsTr("No ESS Assistant found")
		}
	}

	function isBatteryLifeActive(state) {
		switch (state) {
		case batteryLifeStateRestart:
		case batteryLifeStateDefault:
		case batteryLifeStateAbsorption:
		case batteryLifeStateFloat:
		case batteryLifeStateDischarged:
		case batteryLifeStateForceCharge:
		case batteryLifeStateSustain:
		case batteryLifeStateLowSocCharge:
			return true
		default:
			return false
		}
	}

	function isBatterySocGuardActive(state) {
		switch (state) {
		case batterySocGuardDefault:
		case batterySocGuardDischarged:
		case batterySocGuardLowSocCharge:
			return true
		default:
			return false
		}
	}

	VisualItemModel {
		id: hub4Settings

		MbItemOptions {
			function getLocalValue(hub4Mode, state) {
				if (hub4Mode === undefined || state === undefined)
					return undefined
				if (hub4Mode === hub4Disabled)
					return 3
				if (isBatteryLifeActive(state))
					return 0
				if (isBatterySocGuardActive(state))
					return 1
				if (state === batteryKeepCharged)
					return 2
				return 0
			}

			description: qsTr("Mode")
			localValue: getLocalValue(hub4Mode.value, stateItem.value)
			possibleValues:[
				MbOption { description: qsTr("Optimized (with BatteryLife)"); value: 0 },
				MbOption { description: qsTr("Optimized (without BatteryLife)"); value: 1 },
				MbOption { description: qsTr("Keep batteries charged"); value: 2 },
				MbOption { description: qsTr("External control"); value: 3 }
			]
			onLocalValueChanged: {
				if (localValue === undefined)
					return
				// Hub 4 mode
				if (localValue === 3 && hub4Mode.value !== hub4Disabled) {
					hub4Mode.setValue(hub4Disabled)
				} else if (localValue !== 3 && hub4Mode.value === hub4Disabled) {
					hub4Mode.setValue(hub4PhaseCompensation)
				}
				// BatteryLife state
				switch (localValue) {
				case 0:
					if (!isBatteryLifeActive(stateItem.value))
						stateItem.setValue(batteryLifeStateRestart)
					break
				case 1:
					if (!isBatterySocGuardActive(stateItem.value))
						stateItem.setValue(batterySocGuardDefault)
					break
				case 2:
					stateItem.setValue(batteryKeepCharged)
					break
				case 3:
					stateItem.setValue(batteryLifeStateDisabled)
					break
				}
			}
		}

		MbSwitch {
			id: withoutGridMeter
			name: qsTr("Control without grid meter")
			bind: Utils.path(cgwacsPath, '/RunWithoutGridMeter')
			show: hub4Mode.value !== hub4Disabled
			enabled: userHasWriteAccess
		}

		MbSwitch {
			bind: Utils.path(settingsPrefix, "/Settings/SystemSetup/HasAcOutSystem")
			name: qsTr("Inverter AC output in use")
			show: !withoutGridMeter.checked
		}

		MbSwitch {
			VBusItem {
				id: vebusPath
				bind: "com.victronenergy.system/VebusService"
			}
			VBusItem {
				id: doNotFeedInvOvervoltage
				bind: Utils.path(vebusPath.value, "/Hub4/L1/DoNotFeedInOvervoltage")
			}
			name: qsTr("Feed-in excess solarcharger power")
			bind: Utils.path(settingsPrefix, "/Settings/CGwacs/OvervoltageFeedIn")
			show: hub4Mode.value !== hub4Disabled && doNotFeedInvOvervoltage.valid
			enabled: userHasWriteAccess
		}

		MbSwitch {
			name: qsTr("Phase compensation")
			bind: hub4Mode.bind
			valueTrue: hub4PhaseCompensation
			valueFalse: hub4PhaseSplit
			show: hub4Mode.value !== hub4Disabled && stateItem.value !== batteryKeepCharged
			enabled: userHasWriteAccess
			onCheckedChanged: {
				if (initialized && !checked)
					toast.createToast(qsTr("Disabling phase compensation may cause additional energy loss, because extra power has to be sent over DC cables between Multis/Quattros to balance all phases. Disable phase compensation only if your electricy provider does not allow it."), 15000);
			}
		}

		MbSpinBox {
			id: minSocLimit
			description: qsTr("Minimum Discharge SoC (unless grid fails)")
			enabled: userHasWriteAccess
			show: hub4Mode.value !== hub4Disabled && stateItem.value !== batteryKeepCharged
			bind: Utils.path(batteryLifePath, "/MinimumSocLimit")
			numOfDecimals: 0
			unit: "%"
			min: 0
			max: 100
			stepSize: 5
		}

		MbItemValue {
			id: socLimit
			description: qsTr("Actual state of charge limit")
			show: hub4Mode.value !== hub4Disabled && isBatteryLifeActive(stateItem.value)
			item.value: Math.max(minSocLimitItem.value, socLimitItem.value)
			item.unit: '%'
		}

		MbItemOptions {
			description: qsTr("BatteryLife state")
			value: stateItem.value
			readonly: true
			show: hub4Mode.value !== hub4Disabled && isBatteryLifeActive(stateItem.value)
			possibleValues:[
				// Values below taken from MaintenanceState enum in dbus-cgwacs
				MbOption { description: qsTr("Self-consumption"); value: 2 },
				MbOption { description: qsTr("Self-consumption"); value: 3 },
				MbOption { description: qsTr("Self-consumption"); value: 4 },
				MbOption { description: qsTr("Discharge disabled"); value: 5 },
				MbOption { description: qsTr("Slow charge"); value: 6 },
				MbOption { description: qsTr("Sustain"); value: 7 }
			]
		}

		MbSwitch {
			id: maxChargePowerSwitch
			name: qsTr("Limit charge power")
			checked: maxChargePowerItem.value >= 0
			enabled: userHasWriteAccess
			show: hub4Mode.value !== hub4Disabled && !(maxChargeCurrentControl.valid && maxChargeCurrentControl.value)
			onCheckedChanged: {
				if (checked && maxChargePowerItem.value < 0)
					maxChargePowerItem.setValue(1000)
				else if (!checked && maxChargePowerItem.value >= 0)
					maxChargePowerItem.setValue(-1)
			}
		}

		MbSpinBox {
			id: maxChargePower
			description: qsTr("Maximum charge power")
			enabled: userHasWriteAccess
			show: maxChargePowerSwitch.show && maxChargePowerSwitch.checked
			bind: Utils.path(cgwacsPath, "/MaxChargePower")
			numOfDecimals: 0
			unit: "W"
			min: 0
			max: 200000
			stepSize: 50
		}

		MbSwitch {
			id: maxInverterPowerSwitch
			name: qsTr("Limit inverter power")
			checked: maxDischargePowerItem.value >= 0
			enabled: userHasWriteAccess
			show: hub4Mode.value !== hub4Disabled && stateItem.value !== batteryKeepCharged
			onCheckedChanged: {
				if (checked && maxDischargePowerItem.value < 0)
					maxDischargePowerItem.setValue(1000)
				else if (!checked && maxDischargePowerItem.value >= 0)
					maxDischargePowerItem.setValue(-1)
			}
		}

		MbSpinBox {
			id: maxDischargePower
			description: qsTr("Maximum inverter power")
			enabled: userHasWriteAccess
			show: maxInverterPowerSwitch.show && maxInverterPowerSwitch.checked
			bind: Utils.path(cgwacsPath, "/MaxDischargePower")
			numOfDecimals: 0
			unit: "W"
			min: 0
			max: 300000
			stepSize: 50
		}

		MbSwitch {
			name: qsTr("Fronius Zero feed-in")
			bind: Utils.path(cgwacsPath, "/PreventFeedback")
			show: hub4Mode.value !== hub4Disabled
			enabled: userHasWriteAccess
		}

		MbItemValue {
			VBusItem {
				id: pvPowerLimiterActive
				bind: "com.victronenergy.hub4/PvPowerLimiterActive"
			}
			description: qsTr("Fronius Zero feed-in active")
			show: hub4Mode.value !== hub4Disabled && pvPowerLimiterActive.valid
			item.value: pvPowerLimiterActive.value === 0 ? qsTr("No") : qsTr("Yes")
		}

		MbSpinBox {
			description: qsTr("Grid setpoint")
			show: hub4Mode.value !== hub4Disabled && stateItem.value !== batteryKeepCharged
			enabled: userHasWriteAccess
			bind: "com.victronenergy.settings/Settings/CGwacs/AcPowerSetPoint"
			numOfDecimals: 0
			unit: "W"
			stepSize: 10
		}

		MbSubMenu {
			id: deviceItem
			description: qsTr("Debug")
			show: hub4Mode.value !== hub4Disabled && user.accessLevel >= User.AccessSuperUser
			subpage: Component {
				PageHub4Debug { }
			}
		}
	}
}
