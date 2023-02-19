import QtQuick 1.1

Tile {
	id: root

	property bool valid: vItem.value !== undefined
	property alias bind: vItem.bind
	property alias description: _description.text
	property alias extraDescription: _extraDescription.text
	property double stepSize: 0.5
	property int numOfDecimals: 1
	//property bool readOnly
	property string unit: ""
	property real localValue: valid ? value : 0
	property alias value: vItem.value
	property alias item: vItem
	property real min: vItem.min !== undefined ? vItem.min : 0
	property real max: vItem.max !== undefined ? vItem.max : 100
	property int fontPixelSize: 18

	editable: true

	VBusItem {
		id: vItem
	}

	values: [
		TileTextMultiLine {
			id: _description
			width: root.width - 6
			height: visible ? paintedHeight : 0
			visible: text !== ""
		},

		TileText {
			id: _value
			text: format(root.localValue.toFixed(numOfDecimals)) + root.unit
			font.pixelSize: editMode ? root.fontPixelSize + 2 : root.fontPixelSize

			Item {
				visible: root.editMode
				height: 18
				width: root.width - 8
				anchors {
					verticalCenter: _value.verticalCenter
				}

				MbIcon {
					iconId: "icon-toolbar-arrow-up"
					visible: localValue < max
					anchors.top: parent.top
					anchors.right: parent.right
				}

				MbIcon {
					iconId: "icon-toolbar-arrow-down"
					visible: localValue > min
					anchors.bottom: parent.bottom
					anchors.right: parent.right
				}
			}
		},

		TileTextMultiLine {
			id: _extraDescription
			width: root.width - 6
			height: visible ? paintedHeight : 0
		}
	]

	Keys.onSpacePressed: { event.accepted = editMode; edit() }
	Keys.onLeftPressed: { if (editMode) cancel(); event.accepted = false }
	Keys.onRightPressed: { if (editMode) cancel(); event.accepted = false }
	Keys.onDownPressed: {
		if (root.editMode)
			root.localValue -= root.localValue > root.min ? root.stepSize : 0
		event.accepted = editMode
	}
	Keys.onUpPressed: {
		if (root.editMode)
			root.localValue += root.localValue < root.max ? root.stepSize : 0
		event.accepted = editMode
	}

	function edit()
	{
		if (!root.valid || root.readOnly)
			return

		if (root.editMode) {
			vItem.setValue(parseFloat(localValue))
			root.editMode = false
		} else {
			root.editMode = true
		}
	}

	function cancel()
	{
		root.localValue = vItem.value
		root.editMode = false
	}

	function format(val)
	{
		return val
	}

	/* binding is done explicitly to reenable binding after edit */
	Binding {
		target: root
		property: "localValue"
		value: root.value
		when: valid && !editMode
	}
}
