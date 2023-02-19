import QtQuick 1.1

Rectangle {
	id: root

	radius: 6
	width: 110
	height: 110
	color: "#16a185"
	clip: true // hides an off by one pixel offset

	property string title
	property string titleColor :"#1abc9c"
	property alias values: _values.children

	Rectangle {
		id: header
		width: parent.width
		height: 22
		radius: root.radius
		color: titleColor

		// prevent rounded corners at the bottom
		Rectangle {
			height: parent.height / 2
			width: parent.width
			color: parent.color
			anchors.top: parent.verticalCenter
		}

		Text {
			text: title
			font {pixelSize: 14; bold: true}
			color: "white"
			anchors.centerIn: parent
		}
	}

	Item {
		id: _values
		anchors {
			top: header.bottom;
			bottom: root.bottom
			left: root.left
			right: root.right
		}
	}
}
