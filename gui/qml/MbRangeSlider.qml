import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
	id: root
	height: _hintVisible? 185 : 105
	rightText: getRightText()
	rightIcon: ""
	cornerMark: !editMode

	property real minValue: lowItem.min !== undefined ? lowItem.min : 0
	property real maxValue: highItem.max !== undefined ? highItem.max : 100

	property alias description: descriptionText.text
	property real stepSize: 1.0
	property int numOfDecimals: 0
	property string unit
	property bool valid: lowItem.valid && highItem.valid

	property color lowColor: "white"
	property color highColor: "white"

	property alias lowBind: lowItem.bind
	property alias highBind: highItem.bind

	property real lowDisabledValue: minValue
	property real highDisabledValue: minValue

	property real lowDefaultValue: lowItem.def !== undefined ? lowItem.def : 0
	property real highDefaultValue: highItem.def !== undefined ? highItem.def : 0

	/* Enabled is a reserved key word */
	property bool disabled: lowValue === lowDisabledValue && highValue === highDisabledValue
	property bool editMode: false

	property real lowValue: lowItem.valid ? lowItem.value : minValue
	property real highValue: highItem.valid ? highItem.value : maxValue

	property bool showHint: true
	property bool _hintVisible: editMode && showHint

	onHeightChanged: listview.positionViewAtIndex(currentIndex, ListView.Contain)

	Behavior on height {
		PropertyAnimation {
			duration: 300;
		}
	}

	function getRightText() {
		if (!editMode)
			return "default"
		if (disabled)
			return qsTr("Default")
		return qsTr("Disable")
	}

	VBusItem {
		id: lowItem
		isSetting: true
	}

	VBusItem {
		id: highItem
		isSetting: true
	}

	Item {
		id: descriptionItem
		height: 35
		width: parent.width

		MbTextDescription {
			id: descriptionText
			color: root.ListView.isCurrentItem ? style.textColorSelected : style.textColor
			anchors {
				left: parent.left
				leftMargin: style.marginDefault
				verticalCenter: parent.verticalCenter
			}
		}
	}

	Item {
		id: sliderItem
		height: 70
		width: parent.width
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: descriptionItem.bottom
			topMargin: -6
		}

		Rectangle {
			id: slider
			height: 5
			width: parent.width - 50
			color: "lightgrey"
			border.width: 1
			border.color: "#fff"
			anchors.centerIn: parent

			Rectangle {
				id: lowValueHandle
				x: (slider.width - (slider.x - 10)) / (maxValue - minValue) * (lowValue - minValue)
				width: 20
				height:  20
				radius: width * 0.5
				border.color: "#ddd"
				border.width: 2
				color: disabled ? "grey" : lowColor
				anchors.verticalCenter: parent.verticalCenter
				z: 1

				Behavior on x {
					NumberAnimation {
						duration: 200
					}
				}

				Rectangle {
					height: 18
					width: lowValueLabel.paintedWidth <= 45 ? lowValueLabel.paintedWidth + 5 : 45
					radius: 3
					color: "#ddd"
					visible: !disabled
					anchors {
						horizontalCenter: parent.horizontalCenter
						top: parent.bottom
						topMargin: 3
					}

					MbTextValueSmall {
						id: lowValueLabel
						text: lowValue.toFixed(numOfDecimals) + root.unit
						scale: paintedWidth > parent.width ? (parent.width / paintedWidth) : 1
						anchors.centerIn: parent
						horizontalAlignment: Text.AlignHCenter
					}
				}
			}

			Rectangle {
				id: highValueHandle
				x: (slider.width - slider.x + 10) / (maxValue - minValue) * (highValue - minValue)
				width: 20
				height: 20
				radius: width * 0.5
				border.color: "#ddd"
				border.width: 2
				color: disabled ? "grey" : highColor
				anchors.verticalCenter: parent.verticalCenter
				z: 1

				Behavior on x {
					NumberAnimation {
						duration: 200
					}
				}

				Rectangle {
					height: 18
					width: highValueLabel.paintedWidth + 5 <= 45 ? highValueLabel.paintedWidth + 5 :45
					radius: 3
					color: "#ddd"
					visible: !disabled
					anchors {
						horizontalCenter: parent.horizontalCenter
						bottom: parent.top
						bottomMargin: 3
					}

					MbTextValueSmall {
						id: highValueLabel
						text: highValue.toFixed(numOfDecimals) + root.unit
						scale: paintedWidth > parent.width ? (parent.width / paintedWidth) : 1
						horizontalAlignment: Text.AlignHCenter
						anchors.centerIn: parent
					}
				}
			}

			Rectangle {
				id: rangeBar
				height: 6
				color: "lightblue"
				anchors {
					left: lowValueHandle.right
					right: highValueHandle.left
					verticalCenter: parent.verticalCenter
				}
				z: 0
			}
		}
	}

	Rectangle {
		id: buttonExplanation
		width: parent.width
		height: _hintVisible ? 80 : 0
		anchors.bottom: parent.bottom
		color:"#fff"
		visible: _hintVisible

		Behavior on height {
			PropertyAnimation {
				id: animation
				duration: 300;
			}
		}

		Text {
			id: upDownDescription
			text: qsTr("Change low value")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: _hintVisible && !animation.running
			anchors{
				left: parent.left
				leftMargin: 10
				bottom: parent.bottom
				bottomMargin: 3
			}

			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crossupdown.png"
				anchors{
					horizontalCenter: parent.horizontalCenter
					bottom:parent.top
				}
			}
		}

		Text {
			id: leftRightDescription
			text: qsTr("Change high value")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: _hintVisible && !animation.running
			anchors{
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: 3
			}

			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crossleftright.png"
				anchors{
					horizontalCenter: parent.horizontalCenter
					bottom:parent.top
				}
			}
		}

		Text {
			id: centerDescription
			text: qsTr("Apply changes")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: _hintVisible && !animation.running
			anchors{
				right: parent.right
				rightMargin: 10
				bottom: parent.bottom
				bottomMargin: 3
			}
			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crosscenter.png"
				anchors{
					horizontalCenter: parent.horizontalCenter
					bottom:parent.top
				}
			}
		}

		Rectangle {
			height: 1
			width: parent.width
			color: "#ddd"
			anchors.bottom: parent.bottom
		}
	}

	Binding {
		target: root
		property: "lowValue"
		value: lowItem.value
		when: lowItem.valid && !editMode
	}

	Binding {
		target: root
		property: "highValue"
		value: highItem.value
		when: highItem.valid && !editMode
	}

	function apply() {
		lowItem.setValue(lowValue)
		highItem.setValue(highValue)
	}

	function edit() {
		if (editMode)
			apply()
		editMode = !editMode
	}

	Keys.onUpPressed: {
		if (editMode)
			lowValue += (lowValue < highValue) * stepSize
		event.accepted = editMode
	}

	Keys.onDownPressed: {
		if (editMode)
			lowValue -= (lowValue > minValue) * stepSize
		event.accepted = editMode
	}

	Keys.onRightPressed: {
		if (editMode)
			highValue += (highValue < maxValue) * stepSize
		event.accepted = editMode
	}

	Keys.onLeftPressed: {
		if (editMode)
			highValue -= (highValue > lowValue) * stepSize
		event.accepted = editMode
	}

	Keys.onReturnPressed: {
		if (editMode)
			disabled ? enable() : disable()
		event.accepted = editMode
	}

	Keys.onEscapePressed: {
		editMode = false;
	}

	function disable() {
		lowValue = lowDisabledValue
		highValue = highDisabledValue
	}

	function enable() {
		lowValue = lowDefaultValue
		highValue = highDefaultValue
	}
}
