import QtQuick 1.1
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Device List")

	model: VisualItemModel {
		MbSubMenu {
			id: menuNotifications
			description: qsTr("Notifications")
			item: VBusItem {
				property variant active: NotificationCenter.notifications.filter(
											 function isActive(obj) { return obj.active} )
				value: active.length > 0 ? active.length : ""
			}
			subpage: Component { PageNotifications {} }
		}

		MbSubMenu {
			description: qsTr("Settings")
			subpage: Component { PageSettings {} }
		}
		MbSubMenu {
			description: qsTr("Pi Mods")
			subpage: Component { PageRPI {} }
		}

	}

	Component {
		id: submenuLoader
		MbDevice {
			iconId: "icon-toolbar-enter"
		}
	}

	Component {
		id: vebusPage
		PageVebus {}
	}

	Component {
		id: batteryPage
		PageBattery {}
	}

	Component {
		id: solarChargerPage
		PageSolarCharger {}
	}

	Component {
		id: acInPage
		PageAcIn {}
	}

	Component {
		id: acChargerPage
		PageAcCharger {}
	}

	Component {
		id: tankPage
		PageTankSensor {}
	}

	Component {
		id: motorDrivePage
		PageMotorDrive {}
	}

	Component {
		id: inverterPage
		PageInverter {}
	}

	Component {
		id: pulseCounterPage
		PagePulseCounter {}
	}

	Component {
		id: digitalInputPage
		PageDigitalInput {}
	}

	Component {
		id: temperatureSensorPage
		PageTemperatureSensor {}
	}

	function addService(service)
	{
		var name = service.name

		var page
		switch(service.type)
		{
		case DBusService.DBUS_SERVICE_MULTI:
			page = vebusPage
			break;
		case DBusService.DBUS_SERVICE_BATTERY:
			page = batteryPage
			break;
		case DBusService.DBUS_SERVICE_SOLAR_CHARGER:
			page = solarChargerPage
			break;
		case DBusService.DBUS_SERVICE_PV_INVERTER:
			page = acInPage
			break;
		case DBusService.DBUS_SERVICE_AC_CHARGER:
			page = acChargerPage
			break;
		case DBusService.DBUS_SERVICE_TANK:
			page = tankPage
			break;
		case DBusService.DBUS_SERVICE_GRIDMETER:
			page = acInPage
			break
		case DBusService.DBUS_SERVICE_GENSET:
			page = acInPage
			break
		case DBusService.DBUS_SERVICE_MOTOR_DRIVE:
			page = motorDrivePage
			break
		case DBusService.DBUS_SERVICE_INVERTER:
			page = inverterPage
			break;
		case DBusService.DBUS_SERVICE_TEMPERATURE_SENSOR:
			page = temperatureSensorPage
			break;
		case DBusService.DBUS_SERVICE_SYSTEM_CALC:
			return;
		case DBusService.DBUS_SERVICE_DIGITAL_INPUT:
			page = digitalInputPage
			break;
		case DBusService.DBUS_SERVICE_PULSE_COUNTER:
			page = pulseCounterPage
			break;
		default:
			console.log("unknown service " + name)
			return;
		}

		var submenu = submenuLoader.createObject(root)
		submenu.service = service

		// option 1, load when being opened
		// submenu.subpage = page
		// submenu.subpageProperties = {service: service}

		// option 2, create it now
		submenu.subpage = page.createObject(submenu, {service: service, bindPrefix: service.name})

		// sort on (initial) description
		var i = 0
		for (i = 0; i < model.count - 2; i++ ) {
			if (model.children[i].description.localeCompare(service.description) > 0)
				break;
		}

		model.insert(i, submenu)
	}

	Component.onCompleted: {
		for (var i = 0; i < DBusServices.count; i++)
			addService(DBusServices.at(i))
		listview.currentIndex = 0
	}

	Connections {
		target: DBusServices
		onDbusServiceFound: addService(service)
	}
}
