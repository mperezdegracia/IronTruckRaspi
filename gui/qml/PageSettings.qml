import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	title: qsTr("Settings")
	property string bindPrefix: "com.victronenergy.settings"
	property VBusItem relay0Item: VBusItem {bind: "com.victronenergy.system/Relay/0/State"}
	property bool hasRelay0: relay0Item.valid

	model: VisualItemModel {
		MbSubMenu {
			id: generalItem
			description: qsTr("General")
			subpage: Component {
				PageSettingsGeneral {
					title: generalItem.description
				}
			}
		}

		MbSubMenu {
			description: qsTr("Firmware")
			subpage: Component {
				PageSettingsFirmware {
					title: qsTr("Firmware")
				}
			}
		}

		MbSubMenu {
			description: qsTr("Date & Time")
			subpage: Component {
				PageTzInfo {
					title: qsTr("Date & Time")
				}
			}
		}

		MbSubMenu {
			description: qsTr("Remote Console")
			subpage: Component { PageSettingsRemoteConsole {} }
		}

		MbSubMenu {
			id: systemSetupItem
			description: qsTr("System setup")
			subpage: Component {
				PageSettingsSystem {
					title: systemSetupItem.description
				}
			}
		}

		MbSubMenu {
			id: displayItem
			description: qsTr("Display & language")
			subpage: Component {
				PageSettingsDisplay {
					title: displayItem.description
				}
			}
		}

		MbSubMenu {
			id: vrmLoggerItem
			description: qsTr("VRM online portal")
			subpage: Component {
				PageSettingsLogger {
					title: vrmLoggerItem.description
				}
			}
		}

		MbSubMenu {
			VBusItem {
				id: systemType
				bind: "com.victronenergy.system/SystemType"
			}
			description: systemType.value === "Hub-4" ? systemType.value : qsTr("ESS")
			subpage: Component { PageSettingsHub4 {} }
		}

		MbSubMenu {
			description: qsTr("Energy meters")
			subpage: Component { PageSettingsCGwacsOverview {} }
		}

		MbSubMenu {
			description: qsTr("PV inverters")
			subpage: Component { PageSettingsFronius {} }
		}

		MbSubMenu {
			show: App.withQwacs
			description: qsTr("Wireless AC sensors")
			subpage: Component { PageSettingsQwacs {} }
		}

		MbSubMenu {
			id: ethernetItem
			description: qsTr("Ethernet")
			subpage: Component { PageSettingsTcpIp {} }
		}

		MbSubMenu {
			description: qsTr("Wi-Fi")
			subpage: VePlatform.hasHostAccessPoint ? wifiWithAP : wifiWithoutAP
			Component { id: wifiWithoutAP; PageSettingsWifi {} }
			Component { id: wifiWithAP; PageSettingsWifiWithAccessPoint {} }
		}

		MbSubMenu {
			description: qsTr("GPS")
			subpage: Component { PageSettingsGps {} }
		}

		MbSubMenu {
			description: qsTr("Generator start/stop")
			subpage: Component { PageRelayGenerator {} }
			show: hasRelay0
		}

		MbSubMenu {
			description: qsTr("Tank pump")
			subpage: Component { PageSettingsTankPump {} }
		}

		MbSubMenu {
			description: qsTr("Relay")
			subpage: Component { PageSettingsRelay {} }
			show: hasRelay0
		}

		MbSubMenu {
			description: qsTr("Services")
			subpage: Component { PageSettingsServices {} }
		}

		MbSubMenu {
			// TODO: Find a better way to check if
			// analog inputs are available on the device
			property VBusItem analogIoSettings: VBusItem {
				bind: Utils.path(bindPrefix,
								 "/Settings/AnalogInput/Resistive/1/Function")
			}
			property VBusItem digitalIoSettings: VBusItem {
				bind: Utils.path(bindPrefix,
								 "/Settings/DigitalInput/1/Type")
			}
			description: qsTr("I/O")
			subpage: Component { PageSettingsIo {} }
			show: digitalIoSettings.valid || digitalIoSettings.valid
		}

		MbSubMenu {
			description: qsTr("Debug")
			subpage: Component { PageDebug {} }
			show: user.accessLevel >= User.AccessService
		}
	}
}
