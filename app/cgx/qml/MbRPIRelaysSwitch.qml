import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
        id: root
        property int index
        property variant current : get_current()
        property alias name: name.text
        property alias bind: vItem.bind
        property alias valid: vItem.valid
        property alias checked: theSwitch.checked
        property alias enabled: theSwitch.enabled
        property variant valueTrue: '1'
        property variant valueFalse:'0'
        property alias value: vItem.value
        property alias item : vItem
        VBusItem {
                id: vItem
        }

	MbTextDescription {
                id: name
                text : current
                anchors {
                        left: parent.left; leftMargin: style.marginDefault
                        verticalCenter: parent.verticalCenter
                }
        }

	Switch {
                id: theSwitch
                anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right; rightMargin: root.style.marginDefault
                }
                checked: vItem.valid && current !== valueFalse;
                enabled: vItem.valid && root.userHasWriteAccess
        }

	function edit() {
                /*
                 * When binding to the dbus change the value there and update after the
                 * change. Also support local changes so the component can be reused.
                 */
                if (enabled)
                        if (bind)
                                current = theSwitch.checked ? valueFalse : valueTrue//vItem.setValue(theSwitch.checked ? valueFalse : valueTrue)
                        else
                            	checked = !checked
 }
	function get_current() {
                return vItem.value[index]
        }
}


