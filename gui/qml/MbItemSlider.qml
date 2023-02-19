import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
	id: root

	property VBusItem item: VBusItem {}
	property alias icondId: icon.iconId
	property bool directUpdates
	property int _valueBeforeEdit
	

	editMode: slider.enabled
	cornerMark: !slider.enabled

	MbIcon {
		id: icon
		anchors.verticalCenter: parent.verticalCenter
	}

	Slider {
		id: slider

		minimumValue: item.min
		maximumValue: item.max
		stepSize: item.step
		enabled: false

		anchors {
			left: icon.right; leftMargin: 5
			right: parent.right; rightMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}

		onValueChanged: if (directUpdates) item.setValue(value)

		/* note: these functions break binding hence the Binding item below */
		Keys.onRightPressed: slider.up()
		Keys.onLeftPressed: slider.down()
		Keys.onUpPressed: slider.up()
		Keys.onDownPressed: slider.down()

		/* Focus is removed to ignore keypresses */
		Keys.onSpacePressed: {
			if (!directUpdates) item.setValue(value)
			root.focus = true
			slider.enabled = false
		}

		Keys.onReturnPressed: {
			if (!directUpdates) item.setValue(value)
			root.focus = true
			slider.enabled = false
		}

		Keys.onEscapePressed: {
			if (directUpdates) item.setValue(_valueBeforeEdit)
			root.focus = true
			slider.enabled = false
		}
	}

	/* binding is done explicitly to reenable binding after edit */
	Binding {
		target: slider
		property: "value"
		value: item.value
		when: item.valid && !slider.enabled
	}

	function edit()
	{
		if (item.valid) {
			_valueBeforeEdit = slider.value
			slider.enabled = true
			slider.focus = true
		}
	}
}
