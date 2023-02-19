import QtQuick 1.1
import com.victron.velib 1.0

MbPage {
	id: root

	property variant service

	model: VisualItemModel {

		MbItemValue {
			description: qsTr("Charge Current Limit (CCL)")
			item.bind: service.path("/Info/MaxChargeCurrent")
		}

		MbItemValue {
			description: qsTr("Max Charge Voltage")
			item.bind: service.path("/Info/MaxChargeVoltage")
		}

		MbItemValue {
			description: qsTr("Battery Low Voltage")
			item.bind: service.path("/Info/BatteryLowVoltage")
		}

		MbItemValue {
			description: qsTr("Discharge Current Limit (DCL)")
			item.bind: service.path("/Info/MaxDischargeCurrent")
		}
	}
}
