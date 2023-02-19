import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	property string bindPrefix: "com.victronenergy.settings/Settings/Gui"

	model: VisualItemModel {
		// note: the backlight is changed during edit, and saved afterwards
		MbItemSlider {
			id: backlight
			show: VePlatform.hasBacklight
			icondId: "icon-items-brightness"
			directUpdates: true
			item {
				min: 15
				max: 90
				step: 5
				value: VePlatform.brightness
				onValueChanged: if (editMode) VePlatform.brightness = item.value;
			}
			writeAccessLevel: User.AccessUser
			onEditModeChanged: if (!editMode) storedBacklight.setValue(item.value)

			VBusItem {
				id: storedBacklight
				bind: Utils.path(bindPrefix, "/Brightness")
			}
		}

		MbItemOptions {
			show: VePlatform.hasScreenSaver
			description: qsTr("Display off time")
			bind: Utils.path(bindPrefix, "/DisplayOff")
			writeAccessLevel: User.AccessUser
			possibleValues: [
				MbOption { description: qsTr("10 sec"); value: 10 },
				MbOption { description: qsTr("30 sec"); value: 30 },
				MbOption { description: qsTr("1 min"); value: 60 },
				MbOption { description: qsTr("10 min"); value: 600 },
				MbOption { description: qsTr("30 min"); value: 1800 },
				MbOption { description: qsTr("Never"); value: 0 }
			]
		}

		MbSwitch {
			bind: Utils.path(bindPrefix, "/MobileOverview")
			name: qsTr("Show boat & motorhome overview")
			// When enabled set OverviewMobile as default overview
			onClicked: if (checked) defaultOverview.setValue("OverviewMobile")
			VBusItem { id: defaultOverview; bind: "com.victronenergy.settings/Settings/Gui/DefaultOverview" }
		}


		MbItemOptions {
			id: languageSelect
			description: qsTr("Language")
			writeAccessLevel: User.AccessUser
			bind: Utils.path(bindPrefix, "/Language")
			possibleValues: [
				MbOption { description: "English"; value: "en" },
				MbOption { description: "Čeština"; value: "cs" },
				MbOption { description: "Deutsch"; value: "de" },
				MbOption { description: "Español"; value: "es" },
				MbOption { description: "Français"; value: "fr" },
				MbOption { description: "Italiano"; value: "it" },
				MbOption { description: "Nederlands"; value: "nl" },
				MbOption { description: "Русский"; value: "ru" },
				MbOption { description: "Svenska"; value: "se" },
				MbOption { description: "Türkçe"; value: "tr" },
				MbOption { description: "中文"; value: "zh" },
				MbOption { description: "العربية"; value: "ar" }
			]
		}
	}
}
