import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0
import net.connman 0.1

MbItem {
	id: root
	cornerMark: !readonly && !editMode
	height: 35

	property ClockModel clock: ClockModel {}

	//Date in format yyyy-MM-dd hh:mm
	property string format: "yyyy-MM-dd hh:mm"
	property string date: vItem.valid ?  Qt.formatDateTime(new Date(vItem.value * 1000) , format) : ""
	property alias bind: vItem.bind

	property real seconds: vItem.valid && !isNaN(vItem.value) ? vItem.value : clock.secondsFromString(date, format)

	// settings
	property string description
	property bool readonly: !userHasWriteAccess
	property bool showHint: true

	// internal
	property string _editText
	property bool hintVisible // set after the transition is done
	property string _ignoreChars: "-:"
	property string _matchString: "0123456789"

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


	NumberAnimation {
		id: blink
		target: textInput
		property: "opacity"
		from: textInput.opacity
		to: !textInput.opacity
		loops: 5
		duration: 350
		onCompleted: textInput.opacity = 1
	}

	VBusItem {
		id: vItem
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
			text: editMode ? _editText : date

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
			color: editMode ? clock.checkDateTime(_editText, format) ? "black" : "red" : "black"
			maximumLength: root.format.length

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
					anchors.bottomMargin: -4
					width: cursorItem.width
					height: parent.parent.focus ? 2 : 0
					border.color: "black"
					border.width: 2
				}
			}

			function save() {
				if (clock.checkDateTime(_editText, format)) {
					if (root.bind)
						vItem.setValue(clock.secondsFromString(_editText, format));

						date = _editText
						editMode = false
						root.focus = true
				}
				else
					blink.running = true
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

				switch(pos) {
					case 5: return parseInt(_editText[6]) > 2 ? 1 : 2;
					case 6: return _editText[5] === '0' ? _matchString.length : 3;
					case 8: return parseInt(_editText[9]) > 1 ? 3 : 4
					case 9: return _editText[8] === '3' ? 2 : _matchString.length;
					case 11: return parseInt(_editText[12]) > 3 ? 2 : 3;
					case 12: return _editText[11] === '2' ? 4 : _matchString.length;
					case 14: return 6;
					default: return _matchString.length;
				}
			}

			// make sure the time of days keeps below 24:00
			function validate(str) {
				if (str[11] === '2' && str[12] > 3)
					str = replaceAt(str, 12, '3');
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
			text: qsTr("Select number")
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
			text: qsTr("Apply changes")
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
