import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
	id: root
	width: pageStack ? pageStack.currentPage.width : 0

	property string description
	property VBusItem item: VBusItem {}
	property string iconId: "icon-toolbar-enter"
	property bool check: false
	property bool indent: false

	MbTextDescription {
		id: checkText
		anchors {
			left: parent.left; leftMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}
		width: root.indent ? 9 : 0
		text: root.check ? "√" : " "
	}

	MbTextDescription {
		id: name
		anchors {
			left: checkText.right; leftMargin: root.indent ? checkText.width : 0
			verticalCenter: parent.verticalCenter
		}
		text: root.description
	}

	Row {
		spacing: 14

		anchors {
			right: icon.left; rightMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}

		Repeater {
			id: repeater
			model: root.item.value && root.item.value.constructor === Array  ? root.item.value.length : 1

			MbTextValue {
				text: repeater.model === 1 ? root.item.text : root.item.value[index]
				opacity: text !== item.invalidText
				MbGreyRect {height: parent.height + 6; width: parent.width + 10}
			}
		}
	}

	MbIcon {
		id: icon
		anchors {
			right: root.right; rightMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}
		iconId: root.iconId + (root.ListView.isCurrentItem ? "-active" : "")
	}
}
