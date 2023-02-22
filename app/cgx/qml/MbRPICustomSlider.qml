import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
        id: root

        property VBusItem item: VBusItem {}
        property alias icondId: icon.iconId
        property bool directUpdates
        property int _valueBeforeEdit
        property alias description: descriptionText.text
        property int current_value: item.value

        editMode: slider.enabled
        cornerMark: !slider.enabled
        MbTextDescription {
                        id: descriptionText
                        color: root.ListView.isCurrentItem ? style.textColorSelected : style.textColor
                        anchors {
                                left: parent.left
                                leftMargin: style.marginDefault
                                verticalCenter: parent.verticalCenter
                        }
                }

        MbIcon {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
        }

	Slider {
                id: slider

                minimumValue: 0
                maximumValue: 1000
                stepSize: 10
                enabled: false

                anchors {
                        left: icon.right; leftMargin: 75
                        right: parent.right; rightMargin: 60
                        verticalCenter: parent.verticalCenter
                }

                //onValueChanged: if (directUpdates) item.setValue(value)

                /* note: these functions break binding hence the Binding item below */
                Keys.onRightPressed: slider.up()
                Keys.onLeftPressed: slider.down()
				Keys.onUpPressed: slider.up()
                Keys.onDownPressed: slider.down()

                /* Focus is removed to ignore keypresses */
                Keys.onSpacePressed: {
                        //if (!directUpdates) item.setValue(value)
						current_value = value
                        root.focus = true
                        slider.enabled = false
                }

                Keys.onReturnPressed: {
                        //if (!directUpdates) item.setValue(value)
						current_value = value

                        root.focus = true
                        slider.enabled = false
                }

                Keys.onEscapePressed: {
                        //if (directUpdates) item.setValue(_valueBeforeEdit)
						current_value = _valueBeforeEdit

                        root.focus = true
                        slider.enabled = false
                }
        }
	Text {
            id: current
            text: slider.value
            font.family: root.style.fontFamily
			font.pixelSize: 20
            color: root.ListView.isCurrentItem ? descriptionText.style.textColorSelected : descriptionText.style.textColor
            anchors{
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
	}


	// binding is done explicitly to reenable binding after edit 
        Binding {
                target: slider
                property: "value"
                value: item.value
                when: item.valid && !slider.enabled  && current_value == item.value 
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
