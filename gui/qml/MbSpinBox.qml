import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
	id: root
	cornerMark: !readOnly && !spinbox.enabled

	property bool valid: vItem.value !== undefined
	property alias bind: vItem.bind
	property string description
	property double stepSize: 0.5
	property int numOfDecimals: 1
	property bool readOnly: !userHasWriteAccess
	property alias unit: unit.text
	property alias localValue: spinbox.value
	property alias value: vItem.value
	property alias item: vItem
	property alias min: spinbox.minimumValue
	property alias max: spinbox.maximumValue
	property bool hasDefault: vItem.def !== undefined

	editMode: spinbox.enabled

	rightIcon: editMode ? hasDefault ? "" : "icon-toolbar-ok" : ""
	rightText: editMode ? hasDefault ? qsTr("Default") : "" : "default"

	signal exitEditMode(bool changed)
	signal maxValueReached()
	signal minValueReached()

	VBusItem {
		id: vItem
		isSetting: true
	}

	MbTextDescription {
		id: name
		anchors {
			left: parent.left; leftMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}

		text: root.description
		opacity: valid ? style.opacityEnabled : style.opacityDisabled
	}

	Rectangle {
		id: graytag
		color: !spinbox.enabled? "#ddd": "#fff"
		radius: 3
		height: spinbox.height + 6
		width:  spinbox.width  + unit.width + 10
		border.color: "#ddd"
		border.width: spinbox.enabled ? 1 : 0
		anchors {
			right: root.right; rightMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}
	}

	MbTextValue {
		id: unit
		item.invalidText: ""
		anchors {
			right: root.right; rightMargin: style.marginDefault + 5
			verticalCenter: spinbox.verticalCenter
		}
	}

	SpinBox {
		id: spinbox

		color: style.color2
		font.pixelSize: name.font.pixelSize
		font.family: name.font.family
		font.bold: false
		minimumValue: vItem.min === undefined ? 0 : vItem.min
		maximumValue: vItem.max === undefined ? 100 : vItem.max
		stepSize: root.stepSize
		enabled: false
		greyed: valid
		numOfDecimals: root.numOfDecimals
		anchors {
			right: unit.left
			verticalCenter: parent.verticalCenter
		}

		/* note: these functions break binding hence the Binding item below */
		Keys.onRightPressed: { if (value === maximumValue) maxValueReached(); spinbox.up(); }
		Keys.onLeftPressed: { if (value === minimumValue) minValueReached(); spinbox.down(); }
		Keys.onUpPressed: { if (value === maximumValue) maxValueReached(); spinbox.up(); }
		Keys.onDownPressed: { if (value === minimumValue) minValueReached(); spinbox.down(); }

		function accept()
		{
			vItem.setValue(value)
			root.focus = true;
			spinbox.enabled = false
			exitEditMode(true)
		}

		/* Focus is removed to ignore keypresses */
		Keys.onSpacePressed: accept()

		Keys.onReturnPressed: {
			if (hasDefault) {
				value = vItem.defaultValue
			} else {
				accept()
			}
		}

		Keys.onEscapePressed: {
			root.focus = true
			spinbox.enabled = false
			exitEditMode(false)
		}
	}

	/* binding is done explicitly to reenable binding after edit */
	Binding {
		target: spinbox
		property: "value"
		value: vItem.value
		when: valid && !spinbox.enabled
	}

	function edit()
	{
		if (valid && !readOnly)
		{
			spinbox.enabled = true
			spinbox.focus = true
		}
	}
}
