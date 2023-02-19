import QtQuick 1.0

Rectangle {
	id: statusBar
	color: "#22313F"
	height: 31
	property alias showAlert: alert.visible
	property bool internetConnected // disabled
	property alias gpsConnected: gpsStatus.visible

	Text {
		id: titleText
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
		}
		text: pageStack.currentPage ? pageStack.currentPage.title : ""
		font {
			pixelSize: 14
			bold: true
		}
		color: "#fff"
	}

	Image {
		id: leftArrow
		source: "image://theme/icon-statusbar-left-arrow"
		anchors {
			left: parent.left; leftMargin: 10
			verticalCenter: parent.verticalCenter
		}
		visible: (pageStack.depth > 1 && pageStack.currentPage.title !== "Pages")

		MouseArea {
			enabled: leftArrow.visible
			anchors.fill: parent
			onClicked: { pageStack.pop() }
		}
	}

	// Status icons and clock
	Row {
		id: statusIcons
		width: childrenRect.width
		spacing: 6
		anchors {
			right: parent.right; rightMargin: 5
			verticalCenter: parent.verticalCenter
		}

		Image {
			id: gpsStatus
			width: sourceSize.width
			visible: false
			source: "image://theme/icon-statusbar-gpsfix"
			anchors.verticalCenter: parent.verticalCenter
		}

		/*
		Image {
			id: netStatus
			width: sourceSize.width
			source: "image://theme/icon-statusbar-connected"
			anchors.verticalCenter: parent.verticalCenter
		}
		*/

		Image {
			id: alert
			width: sourceSize.width
			source: "image://theme/icon-statusbar-warning"
			opacity: opacityFader.value

			Timer {
				id: opacityFader
				property double value: 0.2 + Math.abs(Math.sin(Math.PI / _loops * _counter))
				property int _counter
				property int _loops: 5

				interval: 200
				running: alert.visible
				repeat: true
				onTriggered: if (_counter >= (_loops - 1)) _counter = 0; else _counter++
			}
		}

		Text {
			id: clock
			text: Qt.formatDateTime(new Date(), "hh:mm")
			color: "#FFFFFF"
			font {
				bold: true
				pixelSize: 16
			}

			Timer {
				running: statusBar.visible
				repeat: true
				interval: 1000
				onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh:mm")
			}
		}
	}
}
