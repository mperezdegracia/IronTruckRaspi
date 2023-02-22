import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils


MbPage {
        id: root
        property bool editMode: false
        property string alarmSetting: alarmSettingItem.value
        property int alarm: alarmItem.value
        VBusItem {
                id: alarmItem
                bind: "com.victronenergy.settings/Settings/RpiSensors/0/Alarm"

        }
        VBusItem {
                id: alarmTriggerItem
                bind: "com.victronenergy.settings/Settings/RpiSensors/0/AlarmTrigger"
        }
	VBusItem {
                id: alarmSettingItem
                bind: "com.victronenergy.settings/Settings/RpiSensors/0/AlarmSetting"
        }
	VBusItem {
                id: relay0
                bind: "com.victronenergy.settings/Settings/RpiRelay/0/Name"
        }
	VBusItem {
                id: relay1          
                bind: "com.victronenergy.settings/Settings/RpiRelay/1/Name"
        }

        VBusItem {
          	id: relay2
                bind: "com.victronenergy.settings/Settings/RpiRelay/2/Name"
        }

        VBusItem {
          	id: relay3
                bind: "com.victronenergy.settings/Settings/RpiRelay/3/Name"
        }

        VBusItem {
          	id: relay4
                bind: "com.victronenergy.settings/Settings/RpiRelay/4/Name"
        }

        VBusItem {
          	id: relay5
                bind: "com.victronenergy.settings/Settings/RpiRelay/5/Name"
        }

        VBusItem {
          	id: relay6
                bind: "com.victronenergy.settings/Settings/RpiRelay/6/Name"
        }

        VBusItem {
          	id: relay7
                bind: "com.victronenergy.settings/Settings/RpiRelay/7/Name"
        }






	model: VisualItemModel {

        MbRPIRelaysSwitch {
                id: alarmSw
                name: qsTr("Alarm")
                bind: alarmItem.bind
                valueFalse: 0
                valueTrue: 1
                current: alarm
                onCheckedChanged: {alarm =  checked ? valueTrue : valueFalse
  
                                }
        }
	MbOK {
            id: save
            description: qsTr("Save Changes")
            show: changed()
            onClicked: {
                push_values()
                toast.createToast("Saved Changes");
            }
       }
	MbRPICustomSlider {
            id: slider
            description: qsTr("Trigger")
            item : alarmTriggerItem
            show : alarmSw.checked
        }

	MbRPIRelaysSwitch {
            bind : alarmSettingItem.bind
            name: "Alarm " +  relay0.value 
            show: alarmSw.checked
            index : 0
            onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)}
        }



        MbRPIRelaysSwitch {
            bind : alarmSettingItem.bind
            name: "Alarm " + relay1.value
            show: alarmSw.checked
            index : 1
            onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)}

        }
	MbRPIRelaysSwitch {
            bind : alarmSettingItem.bind
            name: "Alarm " + relay2.value
            show: alarmSw.checked
            index : 2
            onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)}
        }
        MbRPIRelaysSwitch {
            bind : alarmSettingItem.bind
            name: "Alarm " + relay3.value
            show: alarmSw.checked
            index : 3
            onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)}
        }

        MbRPIRelaysSwitch {
                bind : alarmSettingItem.bind
                name : "Alarm " + relay4.value
                show: alarmSw.checked
                index : 4
                onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)}
        }

        MbRPIRelaysSwitch {
                bind : alarmSettingItem.bind
                name: "Alarm " + relay5.value
                show: alarmSw.checked
                index : 5
                onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)}
        }

        MbRPIRelaysSwitch {
                bind : alarmSettingItem.bind
                name: "Alarm " + relay6.value
                show: alarmSw.checked
                index : 6
                onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)}
        }

        MbRPIRelaysSwitch {
                bind : alarmSettingItem.bind
                name: "Alarm " + relay7.value
                show: alarmSw.checked
                index : 7
                onCheckedChanged: {alarmSetting =  update_local_relays(index, checked)}
        }


    }
        function update_local_relays(relay, value){
                const chr = value? '1' : '0'
                if(relay > alarmSetting.length-1) return alarmSetting;
                return alarmSetting.substring(0,relay) + chr + alarmSetting.substring(relay+1);

        }
	function push_values(){
                alarmTriggerItem.setValue(slider.current_value)
                alarmSettingItem.setValue(alarmSetting)
                alarmItem.setValue(alarm)
                editMode = false

        }
	function changed(){

                return alarmSetting !== alarmSettingItem.value || alarm !== alarmItem.value || slider.current_value !== alarmTriggerItem.value
        }

}



