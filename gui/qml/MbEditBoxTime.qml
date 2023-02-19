import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

/* Note: select time of the day in hh:mm */
MbItem {
	id: root
	cornerMark: !readonly && !editMode
	height: _hintVisible ? 115 : 35

	// The value is either bound to the dbus (in seconds) or on time
	// string hh:mm.
	property string time: textInput.text
	property alias bind: vItem.bind

	// settings
	property string description
	property bool readonly: !userHasWriteAccess
	property bool showHint: true

	// read only properties of the selected time in different units
	property int milliSeconds: seconds * 1000
	property int seconds: getTimeSeconds(textInput.text)

	// internal
	property string _editText
	property bool _hintVisible: editMode && showHint
	property string _ignoreChars: ":"
	property string _matchString: "0123456789"

	onHeightChanged: listview.positionViewAtIndex(currentIndex, ListView.Contain)

	Behavior on height {
		PropertyAnimation {
			duration: 300;
		}
	}

	VBusItem {
		id: vItem
	}

	function getTimeFormatted() {
		if (!vItem.valid)
			return "--:--";

		var secs = vItem.value
		var hours = Math.floor((secs % 86400) / 3600);
		var minutes = Math.floor((secs % 3600) / 60);

		return (hours < 10 ? "0" + hours : hours ) + ":" + (minutes < 10 ? "0" + minutes : minutes)
	}

	function getTimeSeconds(str) {
		var a = str.split(':');
		var seconds = parseInt(a[0], 10) * 60 * 60 + parseInt(a[1], 10) * 60;

		return seconds
	}

	MbTextDescription {
		id: name
		height: 35

		anchors {
			left: parent.left; leftMargin: style.marginDefault
			top: parent.top
		}
		verticalAlignment: Text.AlignVCenter
		text: root.description
		isCurrentItem: root.ListView.isCurrentItem || editMode
	}

	Item {
		id: inputItem
		property real cursorWidth: 12.0
		height: 35
		anchors {
			right: parent.right
			top: parent.top
		}

		Rectangle {
			color: editMode ? "#fff" : "#ddd"
			radius: 3
			width: editMode ? textInput.width + 20 : textInput.width + 10
			height: textInput.height + 6
			border.color: "#ddd"
			border.width: editMode ? 1 : 0
			anchors {
				right: parent.right; rightMargin: style.marginDefault
				verticalCenter: textInput.verticalCenter
			}
		}

		TextInput {
			id: textInput
			text: editMode ? _editText :
				  bind != "" ? getTimeFormatted() :
				  time

			anchors {
				right: parent.right; rightMargin: editMode ? style.marginDefault + 10 : style.marginDefault + 5
				top: parent.top; topMargin: (35 - height) / 2
			}

			// When editing the it is nice to have a fix with font, so when changing
			// digits the text does change in length all the time. However this fonts
			// has an zero with a dot in it, with looks inconsitent with the regular
			// font. So only use the fixed with font when editing.
			font.family: editMode ? "DejaVu Sans Mono" : style.fontFamily
			font.pixelSize: style.fontPixelSize
			maximumLength: 5 // chars hh:mm

			cursorDelegate:
				Item {
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
						anchors.bottomMargin: -4
						width: cursorItem.width
						height: parent.parent.focus ? 2 : 0
						border.color: "black"
						border.width: 2
					}
			}

			function save() {
				if (root.bind)
					vItem.setValue(getTimeSeconds(_editText))
				else
					time = _editText
				editMode = false
				root.focus = true
			}

			Keys.onSpacePressed: save()
			Keys.onReturnPressed: save()

			Keys.onEscapePressed: {
				if (editMode) {
					editMode = false
					root.focus = true
				}
			}

			Keys.onUpPressed: cursorUpOrDown(1)
			Keys.onDownPressed: cursorUpOrDown(-1)

			// Prevent popping the page on left key press when editing
			Keys.onLeftPressed: event.accepted = (cursorPosition == 0)

			// javascript lacks a char replace for strings, spell it out
			function replaceAt(str, index, character) {
				return str.substr(0, index) + character + str.substr(index + character.length);
			}

			// Some digit in e.g. time/data loop earlier then 0..9
			function wrapAround(pos) {
				return  pos === 0 ? 3 :							// MSP of hours max 2x
						pos === 1 && _editText[0] === '2' ? 4 :	// 23 is max -> wrap at 4 if hh = 2x
						pos === 3 ? 6 :							// MSP of min is 59
						_matchString.length						// otherwise 10
			}

			// make sure the time of days keeps below 24:00
			function validate(str) {
				if (str[0] === '2' && str[1] > 3)
					str = replaceAt(str, 1, '3');

				return str;
			}

			function cursorUpOrDown(step) {
				// skip the charachters in the ignore string
				var pos = cursorPosition;
				var chr = _editText[pos];
				if (_ignoreChars.indexOf(chr) >= 0)
					return;

				// update string
				var index = _matchString.indexOf(chr)
				if (index < 0) {
					console.log("invalid char in edit box '" + chr + "'")
					return;
				}

				// create new text and make sure it keeps valid
				var wrap = wrapAround(pos)
				index = (index + wrap + step) % wrap;
				var newText = replaceAt(_editText, pos, _matchString[index])
				newText = validate(newText)

				// assign new text, but don't move the cursor!
				_editText = newText
				cursorPosition = pos;
			}
		}
	}

	function edit() {
		if (!readonly) {
			textInput.focus = true
			_editText = textInput.text
			editMode = true
			textInput.cursorPosition = textInput.text.length - 1;
		}
	}

	Rectangle {
		id: buttonExplanation
		width: parent.width
		height: _hintVisible ? 80 : 0
		anchors.bottom: parent.bottom
		color: "#fff"
		visible: height != 0
		property bool expanded: height === 80

		Behavior on height {
			PropertyAnimation {
				duration: 300;
			}
		}

		Text {
			id: leftRightDescription
			text: qsTr("Select position")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: parent.expanded

			anchors {
				left: parent.left; leftMargin: 10;
				bottom: parent.bottom; bottomMargin: 3
			}

			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crossleftright.png"
				anchors {
					horizontalCenter: parent.horizontalCenter
					bottom: parent.top
				}
			}
		}

		Text {
			id: upDownDescription
			text: qsTr("Select number")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: parent.expanded

			anchors {
				horizontalCenter: parent.horizontalCenter;
				bottom: parent.bottom; bottomMargin: 3
			}

			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crossupdown.png"
				anchors {
					horizontalCenter: parent.horizontalCenter
					bottom: parent.top
				}
			}
		}

		Text {
			id: centerDescription
			text: qsTr("Apply changes")
			font.family: root.style.fontFamily
			font.pixelSize: 14
			visible: parent.expanded

			anchors {
				right: parent.right; rightMargin: 10
				bottom: parent.bottom; bottomMargin: 3
			}

			Image {
				height: sourceSize.height
				width: sourceSize.width
				source: "../images/crosscenter.png"
				anchors{
					horizontalCenter: parent.horizontalCenter
					bottom: parent.top
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
