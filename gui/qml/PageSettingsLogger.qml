import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage
{
	id: root
	property string bindSettingsPrefix: "com.victronenergy.settings"
	property string bindVrmloggerPrefix: "com.victronenergy.logger"

	model: VisualItemModel {

		MbItemOptions {
			id: loggerMode
			description: qsTr("Logging enabled")
			bind: Utils.path(bindSettingsPrefix, "/Settings/Vrmlogger/Logmode")
			possibleValues: [
				MbOption { description: qsTr("Disabled"); value: 0 },
				MbOption { description: qsTr("Enabled"); value: 1 }
			]
		}

		MbItemValue {
			description: qsTr("VRM Portal ID")
			item.value: VePlatform.uniqueId
		}

		MbItemOptions {
			description: qsTr("Log interval")
			bind: Utils.path(bindSettingsPrefix, "/Settings/Vrmlogger/LogInterval")
			possibleValues: [
				MbOption { description: qsTr("1 min"); value: 60 },
				MbOption { description: qsTr("5 min"); value: 300 },
				MbOption { description: qsTr("10 min"); value: 600 },
				MbOption { description: qsTr("15 min"); value: 900 },
				MbOption { description: qsTr("30 min"); value: 1800 },
				MbOption { description: qsTr("1 hour"); value: 3600 },
				MbOption { description: qsTr("12 hours"); value: 7200 },
				MbOption { description: qsTr("1 day"); value: 14400 }
			]
			show: loggerMode.valid && loggerMode.value > 0
		}

		MbSwitch {
			name: qsTr("Use secure connection (HTTPS)")
			bind: Utils.path(bindSettingsPrefix, "/Settings/Vrmlogger/HttpsEnabled")
		}

		MbItemValue {
			id: lastcontact
			description: qsTr("Last contact")
			item.bind: Utils.path(bindVrmloggerPrefix, "/Vrm/TimeLastContact")
			show: loggerMode.value === 1
		}

		MbItemValue {
			id: bufferLocation

			property int internal: 0
			property int beingTransfered: 1
			property int external: 2

			description: qsTr("Storage location")
			item.text: locationToText(vBufferLocation.value)

			function locationToText(s)
			{
				switch (s) {
					case internal:
						return qsTr("Internal storage");
					case beingTransfered:
						return qsTr("Transferring");
					case external:
						return qsTr("External storage");
					default:
						return qsTr("No buffer active");
				}
			}

			VBusItem {
				id: vBufferLocation
				bind: Utils.path(bindVrmloggerPrefix, "/Buffer/Location")
			}
		}

		MbItemValue {
			id: bufferErrorState

			property int noError: 0
			property int outOfSpaceError: 1
			property int ioError: 2
			property int mountError: 3
			property int firmwareImageError: 4
			property int notWritableError: 5

			description: qsTr("Error")
			item.text: errorToText(vBufferErrorState.value)
			show: vBufferErrorState.value != 0


			function errorToText(error)
			{
				switch (error)
				{
					case noError:
						return qsTr("No Error");
					case outOfSpaceError:
						return qsTr("No space left on storage");
					case ioError:
						return qsTr("IO error");
					case mountError:
						return qsTr("Mount error");
					case firmwareImageError:
						return qsTr("Contains firmware image. Not using.");
					case notWritableError:
						return qsTr("SD card / USB stick not writable");
					default:
						return qsTr("Unknown error");
				}
			}

			VBusItem {
				id: vBufferErrorState
				bind: Utils.path(bindVrmloggerPrefix, "/Buffer/ErrorState")
			}
		}

		MbItemValue {
			description: qsTr("Free disk space")
			item {
				bind: Utils.path(bindVrmloggerPrefix, "/Buffer/FreeDiskSpace")
				text: Utils.qtyToString(item.value, qsTr("byte"), qsTr("bytes"))
			}
		}

		MbOK {
			property int notMounted: 0
			property int mounted: 1
			property int unmountRequested: 2
			property int unmountBusy: 3

			function mountStateToText(s)
			{
				switch (s) {
				case mounted:
					return qsTr("Press to eject");
				case unmountRequested:
				case unmountBusy:
					return qsTr("Ejecting, please wait");
				default:
					return qsTr("No storage found");
				}
			}

			VBusItem {
				id: vMountState
				bind: Utils.path(bindVrmloggerPrefix, "/Storage/MountState")
			}
			description: qsTr("microSD / USB")
			value: mountStateToText(vMountState.value)
			writeAccessLevel: User.AccessUser
			onClicked: vMountState.setValue(unmountRequested);
			editable: vMountState.value === mounted
			cornerMark: false
		}

		MbItemValue {
			description: qsTr("Stored records")
			item {
				bind: Utils.path(bindVrmloggerPrefix, "/Buffer/Count")
				text: Utils.qtyToString(item.value, qsTr("item"), qsTr("records"))
			}
		}

		MbItemValue {
			id: oldestBacklogItemAge
			description: qsTr("Oldest record age")
			item.bind: Utils.path(bindVrmloggerPrefix, "/Buffer/OldestTimestamp")
		}
	}

	// update every second to turn timestamp into time ago
	Timer {
		interval: 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			lastcontact.item.text = Utils.timeAgo(lastcontact.item.value)
			oldestBacklogItemAge.item.text = Utils.timeAgo(oldestBacklogItemAge.item.value)
		}
	}
}
