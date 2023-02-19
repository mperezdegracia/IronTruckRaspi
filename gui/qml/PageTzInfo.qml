import QtQuick 1.1
import com.victron.velib 1.0
import net.connman 0.1

// Page showing the current Date Time selection
MbPage {
	id: pageTzInfo
	property ClockModel clock: ClockModel {}

	model: VisualItemModel {

		MbItemValue {
			id: dateUTC
			description: qsTr("Date/Time UTC")

			Timer {
				interval: 1000
				running: parent.visible
				repeat: true
				triggeredOnStart: true
				onTriggered: dateUTC.item.value = VePlatform.getUTCDateTime()
			}
		}

		MbEditBoxDateTime {
			id: dateLocal
			description: qsTr("Date/Time local")
			writeAccessLevel: User.AccessUser
			date: VePlatform.getLocalDateTime()
			onDateChanged: {

				// Connman disables the manual time setting when TimeUpdates is set to "auto",
				// so TimeUpdates has to be changed to "manual" before setting the time then is changed
				// back to "auto" after the date is set.
				// The time will be automatically updated when the color control is connected to internet.
				if(clock.ready()) {
					if (clock.timeUpdates === "auto") {
						clock.timeUpdates = "manual"
						clock.setDateTimeFromString(date, format)
						clock.timeUpdates = "auto"
						return
					}
					clock.setDateTimeFromString(date, format)
				}
			}

			function update() {dateLocal.date = VePlatform.getLocalDateTime()}

			Timer {
				interval: 1000
				running: parent.visible && !dateLocal.editMode
				repeat: true
				onTriggered: dateLocal.update()
			}

			Connections {
				target: TimeZone
				onCityChanged: dateLocal.update()
			}

		}

		MbItemValue {
			id: tzItem
			description: qsTr("Time zone")
			item.value: getTimeZoneLabel()

			function getTimeZoneLabel()
			{
				if (TimeZone.city === "UTC")
					return TimeZone.city

				var component = Qt.createComponent("Tz" + TimeZone.region + "Data.qml");
				var tzData = component.createObject(tzItem)
				for (var i = 0; i < tzData.count; i++) {
					if (tzData.get(i).city === TimeZone.city)
							return tzData.get(i).name
				}
			}
		}

		MbSubMenu {
			description: qsTr("Change time zone")
			subpage: Component {
				PageTzMenu {
					title: qsTr("Regions")
				}
			}
		}
	}
}
