import QtQuick 1.1

Item {
	id: root

	width: 145
	height: 101

	property real soc: 80
	property string color: "#4789d0"
	property string emptyColor: "#1abc9c"
	property alias values: _values.children

	Rectangle {
		id: leftTerminal
		width: 12
		height: 8
		radius: 3
		color: soc < 100 ? emptyColor : root.color
		anchors {
			left: root.left; leftMargin: 12
		}
		x: 12
	}

	Rectangle {
		id: rightTerminal
		width: 12
		height: 8
		radius: 3
		color: soc < 100 ? emptyColor : root.color
		anchors {
			right: root.right; rightMargin: 12
		}
	}

	Rectangle {
		id: background

		// NOTE: to remove the bottom of the terminals
		border {width: 2; color: "white"}

		anchors {
			top: leftTerminal.bottom; topMargin: -1
			bottom: root.bottom
			left: root.left
			right: root.right
		}

		Rectangle {
			anchors.fill: parent
			color: root.emptyColor
			radius: 3
		}

		Rectangle {
			id: filledPart
			width: root.width
			height: soc * background.height / 100
			color: root.color
			anchors.bottom: parent.bottom
			radius: 3
		}

		Rectangle {
			height: parent.height
			width: parent.width * 0.7
			anchors.centerIn: parent
			color: "#10ffffff"
		}
	}

	Text {
		text: "-"
		font.pixelSize: 13; font.bold: true
		anchors.centerIn: leftTerminal
		anchors.verticalCenterOffset: 12
		color: "#fff"
	}

	Text {
		text: "+"
		font.pixelSize: 13; font.bold: true
		anchors.centerIn: rightTerminal
		anchors.verticalCenterOffset: 12
		color: "#fff"
	}

	Item {
		id: _values
		anchors {
			top: background.top;
			bottom: root.bottom
			left: root.left
			right: root.right
		}
	}
}
