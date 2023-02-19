import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils


MbPage {
	id: root
	model: VisualItemModel {
        MbSwitch {
            name: qsTr("Alarm")
            bind: "com.victronenergy.settings/Settings/RpiSensors/0/Alarm"
        }
        MbSubMenu {
            id: relay_settings
            description: qsTr("Relay Alarm Configuration")
            subpage: Component {
                PageRPIRelaysConfiguration {
                    title: relayOverviewItem.description
                }
            }
        }
        MbItemSlider {
            description: qsTr("Trigger")
            item : VBusItem {bind: "com.victronenergy.settings/Settings/RpiSensors/0/AlarmTrigger"}
        }

        MbRPIRelaySwitch {
            name: qsTr("Alarm Relay")
            bind: "com.victronenergy.settings/Settings/RpiSensors/0/AlarmSetting"
 
        }

    


    }

}