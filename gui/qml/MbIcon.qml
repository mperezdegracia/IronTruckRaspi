import QtQuick 1.1
import Qt.labs.components.native 1.0

Image {
	id: root

	property string iconId

	source: iconId == "" ? "" : "image://theme/" + iconId
	width: sourceSize.width
	height: sourceSize.height
	smooth: true
}
