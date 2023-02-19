import QtQuick 1.1

Rectangle {
	width: 480
	height: 272
	color: "grey"

	Rectangle {
		id: one
		x: 50
		y: 50
		width: 20
		height: 50
		color: "blue"
	}

	Rectangle {
		id: two
		x: 400
		y: 180
		width: 50
		height: 50
		color: "red"
	}

	OverviewConnection {
		ballCount: 5
		path: corner
		active: true

		anchors {
			left: one.right; top: one.verticalCenter
			right: two.right; bottom: two.verticalCenter
		}

		// prevent: QDeclarativeComponent: Cannot create new component
		// instance before completing the previous
		Component.onCompleted: value = -1
	}

	OverviewConnection {
		ballCount: 5
		path: corner
		active: true

		anchors {
			left: two.left; top: two.verticalCenter
			right: one.left; bottom: one.verticalCenter
		}

		// prevent: QDeclarativeComponent: Cannot create new component
		// instance before completing the previous
		Component.onCompleted: value = -1
	}
}

