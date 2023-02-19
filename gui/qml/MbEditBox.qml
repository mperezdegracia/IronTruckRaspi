import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
	id: root
	cornerMark: !readonly && !editMode
	height: 35

	property alias text: ti.text
	property alias maximumLength: ti.maximumLength
	property string tmpText: text
	property string matchString: "0123456789 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()-_=+[]{}\;:|/.,<>?"
	property string ignoreChars
	property bool removeSpaces: false
	property bool readonly: !userHasWriteAccess
	property bool insert: false
	property alias item: vItem
	property bool valid: vItem.bind ? vItem.value !== undefined : true
	property alias bind: vItem.bind
	property string description
	property bool showHint: true
	property bool hintVisible // set after the transition is done
	property bool enableSpaceBar: false
	signal textChanged(string newText)

	onHintVisibleChanged: {
		if (hintVisible)
			listview.positionViewAtIndex(currentIndex, ListView.Contain)
	}

	state: editMode && showHint ? "expanded" : "normal"

	transitions: [
		Transition  {
			from: "normal"
			to: "expanded"
			SequentialAnimation {
				PropertyAnimation { target: root; property: "height"; to: 115; duration: 300}
				PropertyAnimation { target: root; property: "hintVisible"; to: true }
			}
		},
		Transition  {
			from: "expanded"
			to: "normal"
			SequentialAnimation {
				PropertyAnimation { target: root; property: "hintVisible"; to: false }
				PropertyAnimation { target: root; property: "height"; to: 35; duration: 300}
			}
		}
	]

	VBusItem {
		id: vItem
	}

	function restoreOriginalText() {
		text = tmpText
	}

	MbTextDescription {
		id: name
		height: 35

		anchors {
			left: parent.left;
			leftMargin: style.marginDefault
			top: parent.top
		}
		verticalAlignment: Text.AlignVCenter
		text: root.description
		isCurrentItem: root.ListView.isCurrentItem || editMode
	}

	Item {
		id: inputItem

		property real cursorWidth: 8.0
		height: 35
		anchors {
			right: parent.right
			top: parent.top
		}

		Rectangle {
			id: greytag
			color: editMode ? "#fff": "#ddd"
			radius: 3
			width: editMode ? ti.width + 20 : ti.width + 10
			height: ti.height + 6
			border.color: "#ddd"
			border.width: editMode ? 1 : 0
			anchors {
				right: parent.right; rightMargin: style.marginDefault
				verticalCenter: ti.verticalCenter
			}
		}

		TextInput {
			id: ti
			anchors{
				right: parent.right
				rightMargin: editMode ? style.marginDefault + 10 : style.marginDefault + 5
				top: parent.top
				topMargin: (35 - height) / 2
			}

			// When editing the it is nice to have a fix with font, so when changing
			// digits the text does change in length all the time. However this fonts
			// has an zero with a dot in it, with looks inconsitent with the regular
			// font. So only use the fixed with font when editing.
			font.family: editMode ? "DejaVu Sans Mono" : style.fontFamily
			font.pixelSize: style.fontPixelSize
			maximumLength: 20

			cursorDelegate: Item {
				id: cursorItem
				width: parent.parent.cursorWidth // inputItem.cursorWidth does not work

				Rectangle {
					anchors.top: cursorItem.top
					anchors.topMargin: -1
					width: cursorItem.width
					height: parent.parent.focus ? 2 : 0
					border.color: "black"
					border.width: 2
				}

				Rectangle {
					anchors.bottom: cursorItem.bottom
					anchors.bottomMargin: -2
					width: cursorItem.width
					height: parent.parent.focus ? 2 : 0
					border.color: "black"
					border.width: 2
				}
			}

			Keys.onSpacePressed: {
				if (enableSpaceBar) {
					event.accepted = false;
					return
				}

				editMode = false
				root.focus = true
				text = removeSpaces ? text.replace(/\s+/g, "") : text.trim()
				root.textChanged(text)
				if (root.bind)
					vItem.setValue(text)
			}

			Keys.onReturnPressed: {
				editMode = false
				root.focus = true
				text = removeSpaces ? text.replace(/\s+/g, "") : text.trim()
				root.textChanged(text)
				if (root.bind)
					vItem.setValue(text)
			}

			Keys.onEscapePressed: {
				editMode = false
				root.focus = true
				text = tmpText
			}

			Keys.onUpPressed: cursorUpOrDown(1)
			Keys.onDownPressed: cursorUpOrDown(-1)

			// Prevent popping the page on left key press when editing
			Keys.onLeftPressed: event.accepted = (cursorPosition == 0)

			function cursorUpOrDown (changer) {
				var oldPosition = cursorPosition;
				var newChar;
				var oldChar = text.charAt(cursorPosition);
				if (oldChar === '') oldChar = ' '
				var matchIndex = root.matchString.indexOf(oldChar);

				if (ignoreChars.indexOf(oldChar) < 0) {
					if (matchIndex < 0) { // No match, start newChar with first or last accepted char
						if (changer > 0)
							newChar = root.matchString.charAt(0);
						else
							newChar = root.matchString.charAt(root.matchString.length-1);
					} else {
						if (changer > 0) // Match and going Up
							if (matchIndex >= root.matchString.length-1)
								newChar = root.matchString.charAt(0);
							else
								newChar = root.matchString.charAt(matchIndex+1);
						else // Match and going down
							if (matchIndex <= 0)
								newChar = root.matchString.charAt(root.matchString.length-1);
							else
								newChar = root.matchString.charAt(matchIndex-1);
					}
					text = text.substring(0, cursorPosition) + newChar + text.substring(cursorPosition + 1, text.length);
				}
				cursorPosition = oldPosition;
			}
		}
	}

	function edit() {
		if (!readonly) {
			ti.focus = true
			editMode = true
			tmpText = text
			ti.cursorPosition = 0;
		}
	}

	Rectangle {
		id: buttonExplanation
		width: parent.width
		anchors {
			top: inputItem.bottom
			bottom: parent.bottom
		}
		color:"#fff"

		Text {
			id: leftRightDescription
			text: qsTr("Select position")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: root.hintVisible
			anchors {
				left: parent.left; leftMargin: 10;
				bottom: parent.bottom; bottomMargin: 1
			}

			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crossleftright.png"
				anchors{
					horizontalCenter: parent.horizontalCenter
					bottom:parent.top
				}
			}
		}

		Text {
			id: upDownDescription
			text: qsTr("Select character")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: root.hintVisible
			anchors {
				horizontalCenter: parent.horizontalCenter;
				bottom: parent.bottom; bottomMargin: 1
			}

			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crossupdown.png"
				anchors {
					horizontalCenter: parent.horizontalCenter
					bottom:parent.top
				}
			}
		}

		Text {
			id: centerDescription
			text: enableSpaceBar ? qsTr("Add space") : qsTr("Apply changes")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: root.hintVisible
			anchors {
				right: parent.right; rightMargin: 10;
				bottom: parent.bottom; bottomMargin: 1
			}

			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crosscenter.png"
				anchors {
					horizontalCenter: parent.horizontalCenter
					bottom:parent.top
				}
			}
		}

		Rectangle {
			height: 1
			width: parent.width
			color: "#ddd"
			anchors.bottom: parent.bottom
		}
	}
}
