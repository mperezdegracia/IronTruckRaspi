import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils


MbPage {
        id: root
        property bool editMode: false
        property string alarmSetting: alarmSettingItem.value
        property int alarm: alarmItem.value
        VBusItem {
                id: alarmTriggerItem
                bind: "com.victronenergy.settings/Settings/RpiSensors/0/Alarm"

        }
        VBusItem {
                id: alarmItem
                bind: "com.victronenergy.settings/Settings/RpiSensors/0/AlarmTrigger"
        }
	VBusItem {
                id: alarmSettingItem
                bind: "com.victronenergy.settings/Settings/RpiSensors/1/AlarmSetting"
        }



	model: VisualItemModel {

        MbRPIRelaysSwitch {
                id: alarm
                name: qsTr("Alarm")
                bind: alarmItem.bind
                valueFalse: 0
                valueTrue: 1
                current: alarmItem.value
                onCheckedChanged: {alarm =  checked ? valueTrue : valueFalse
                                   editMode = true        
                                }
        }
	MbOK {
            id: save
            description: qsTr("Save Changes")
            show: changed()
            property VBusItem aSetting: VBusItem { bind: "com.victronenergy.settings/Settings/RpiSensors/1/AlarmSetting" }
            onClicked: {
            //     push_value()
                push_values()
                toast.createToast("Saved Changes " + aSetting.value);
            }
       }
	MbRPICustomSlider {
            id: slider
            description: qsTr("Trigger")
            item : alarmTriggerItem
            show : alarm.checked
        }

	MbRPIRelaysSwitch {
            bind : alarmSettingItem.bind
            name: "Alarm Relay 1 State"
            show: alarm.checked
            index : 0
            onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)
                                editMode = true        
                                }
        }



        MbRPIRelaysSwitch {
            bind : alarmSettingItem.bind
            name: "Alarm Relay 2 State"
            show: alarm.checked
            index : 1
            onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)
                                editMode = true        
                        }

        }
	MbRPIRelaysSwitch {
            bind : alarmSettingItem.bind
            name: "Alarm Relay 3 State"
            show: alarm.checked
            index : 2
            onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)
                editMode = true        
                }
        }
        MbRPIRelaysSwitch {
            bind : alarmSettingItem.bind
            name: "Alarm Relay 4 State"
            show: alarm.checked
            index : 3
            onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)
                editMode = true        
                }
        }

        MbRPIRelaysSwitch {
                bind : alarmSettingItem.bind
                name: "Alarm Relay 5 State"
                show: alarm.checked
                index : 4
                onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)
                        editMode = true        
                        }
                }

        MbRPIRelaysSwitch {
                bind : alarmSettingItem.bind
                name: "Alarm Relay 6 State"
                show: alarm.checked
                index : 5
                onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)
                        editMode = true        
                        }
                }

        MbRPIRelaysSwitch {
                bind : alarmSettingItem.bind
                name: "Alarm Relay 7 State"
                show: alarm.checked
                index : 6
                onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)
                        editMode = true        
                        }
                }

        MbRPIRelaysSwitch {
                bind : alarmSettingItem.bind
                name: "Alarm Relay 8 State"
                show: alarm.checked
                index : 7
                onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)
                        editMode = true        
                        }
                }


    }
        function update_local_relays(relay, value){
                const chr = value? '1' : '0'
                if(relay > alarmSetting.length-1) return alarmSetting;
                return alarmSetting.substring(0,relay) + chr + alarmSetting.substring(relay+1);

        }
	function push_values(){
                alarmTriggerItem.setValue(slider._valueBeforeEdit)
                alarmSettingItem.setValue(alarmSetting)
                alarmItem.setValue(alarm)
                editMode = false

        }
	function changed(){

                return alarmSetting !== alarmSettingItem.value
        }

}







