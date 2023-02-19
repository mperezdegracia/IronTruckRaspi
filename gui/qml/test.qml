import QtQuick 1.1

import Qt.labs.components.native 1.0
import com.victron.velib 1.0

PageStackWindow {
	id: rootWindow

	initialPage: PageTest {}

	Toast {
		id: toast;
		duration: 2000
	}

	// stolen from main.qml
	ToolBarLayout {
		id: mbTools
		height: parent.height

		Item {
			anchors.verticalCenter: parent.verticalCenter
			anchors.left: mbTools.left
			height: mbTools.height
			width: 200

			Row {
				anchors.centerIn: parent

				MbIcon {
					anchors.verticalCenter: parent.verticalCenter
					iconId: pageStack.currentPage ? pageStack.currentPage.leftIcon : ""
				}

				Text {
					anchors.verticalCenter: parent.verticalCenter
					text: pageStack.currentPage ? pageStack.currentPage.leftText : ""
					color: "white"
					font.bold: true
					font.pixelSize: 16
				}
			}
		}

		MbIcon {
			id: centerScrollIndicator

			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter: mbTools.verticalCenter
			}
			iconId: pageStack.currentPage ? pageStack.currentPage.scrollIndicator : ""
		}

		Item {
			anchors.verticalCenter: parent.verticalCenter
			height: mbTools.height
			anchors.right: mbTools.right
			width: 200

			Row {
				anchors.centerIn: parent

				MbIcon {
					iconId: pageStack.currentPage ? pageStack.currentPage.rightIcon : ""
					anchors.verticalCenter: parent.verticalCenter
				}

				Text {
					text: pageStack.currentPage ? pageStack.currentPage.rightText : ""
					anchors.verticalCenter: parent.verticalCenter
					color: "white"
					font.bold: true
					font.pixelSize: 16
				}
			}
		}
	}
}
