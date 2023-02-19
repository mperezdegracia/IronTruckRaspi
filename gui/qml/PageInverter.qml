import QtQuick 1.1
import com.victron.velib 1.0

MbPage {
	id: root

	property variant service
	property string bindPrefix

	title: service.description
	summary: acPower.item.text

	model: VisualItemModel {
		MbItemOptions {
			description: qsTr("Switch")
			bind: service.path("/Mode")

			possibleValues: [
				MbOption { description: qsTr("Off"); value: 4 },
				MbOption { description: qsTr("On"); value: 2 },
				MbOption { description: qsTr("Eco"); value: 5 }
			]
		}

		MbItemValue {
			SystemState {
				id: state
				bind: root.service.path("/State")
			}
			description: qsTr("State")
			item.text: state.text
		}

		MbItemRow {
			description: qsTr("AC-Out")
			values: [
				MbTextBlock {
					id: acVoltage
					item.bind: service.path("/Ac/Out/L1/V")
					item.decimals: 0
					item.unit: "V"
					width: 90
					visible: item.valid
					height: 25
				},
				MbTextBlock {
					id: acCurrent
					item.bind: service.path("/Ac/Out/L1/I")
					item.text: Math.max(0, item.value).toFixed(1) + "A"
					width: 90
					visible: item.valid
					height: 25
				},
				MbTextBlock {
					id: acPower
					property double power: acVoltage.item.valid && acCurrent.item.valid ?
											   Math.max(0, acVoltage.item.value * acCurrent.item.value) :
											   0

					item.value: Math.round(power / 25) * 25
					item.unit: "W"
					item.decimals: 0
					width: 90
					visible: acVoltage.item.valid && acCurrent.item.valid
					height: 25
				}
			]
		}

		MbItemValue {
			description: qsTr("DC")
			item.bind: service.path("/Dc/0/Voltage")
		}

		MbSubMenu {
			id: supportedDeviceItem
			description: qsTr("Device")
			subpage: Component {
				PageDeviceInfo {
					title: supportedDeviceItem.description
					bindPrefix: root.bindPrefix
				}
			}
		}
	}
}
