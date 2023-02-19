import QtQuick 1.1

Rectangle {
	id: greyRect
	height: parent.height
	width: parent.width
	color: "#ddd"
	radius: 3
	anchors.centerIn: parent
	visible: parent.text !== "" && parent.text !== " "
	z: -1
}
