import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	title: qsTr("Pi Mods")
	property string bindPrefix: "com.victronenergy.settings"
	model: VisualItemModel {
		MbSubMenu {
			id: relayOverviewItem
			description: qsTr("Pi-Relays")
			subpage: Component {
				PageRPIRelaysOverview {
					title: relayOverviewItem.description
				}
			}
		}

			MbSubMenu {
			id: piSensors
			description: qsTr("Pi-Sensors")
			subpage: Component {
				PageRPISensorsOverview {
					title: piSensors.description
				}
			}
		}







	}

}
