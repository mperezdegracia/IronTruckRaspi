import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	title: qsTr("Setup")

	property string bindPrefix

	model: VisualItemModel {
		MbItemOptions {
			id: volumeUnit
			description: qsTr("Volume unit")
			bind: "com.victronenergy.settings/Settings/System/VolumeUnit"
			possibleValues: [
				MbOption { description: qsTr("Cubic metre"); value: 0 },
				MbOption { description: qsTr("Litre"); value: 1 },
				MbOption { description: qsTr("Imperial gallon"); value: 2 },
				MbOption { description: qsTr("U.S. gallon"); value: 3 }
			]
			onValueChanged: capacityItem.update()
		}

		MbSwitch {
			name: qsTr("Inverted")
			bind: Utils.path(settingsBindPreffix, "/InvertTranslation")
		}

		MbSpinBox {
			description: qsTr("Multiplier")
			bind: Utils.path(settingsBindPreffix, "/Multiplier")
			numOfDecimals: 1
			stepSize: 0.1
			min: 0.1
			max: 1000
		}

		MbOK {
			description: qsTr("Reset counter")
			value: itemCount.value
			editable: true
			onClicked: {
				itemCount.setValue(0)
			}
			VBusItem {
				id: itemCount
				bind: Utils.path(bindPrefix, "/Count")
			}
		}
	}
}
