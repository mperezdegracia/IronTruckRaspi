import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

/* Displays a setting and provides a submenu to select an different option */
MbItem {
	id: root
	cornerMark: !readonly

	property alias description: description.text
	property string iconId
	property list<MbOption>  possibleValues
	property alias bind: vItem.bind
	property alias valid: vItem.valid
	property variant localValue: ""
	property variant value: root.valid ? vItem.value : root.localValue
	property bool showOldSelection;
	property Page childPage;
	property bool readonly: !userHasWriteAccess
	property bool greyed: false
	property bool magicKeys: false
	property int upCount: 0
	property int downCount: 0
	property alias text: valueText.text
	property string unknownOptionText: qsTr("Unknown")
	property alias item: vItem

	states: [
		State {
			name: ""
		},
		State {
			name: "closing"
		}
	]

	MbStyle {
		id: styleItem
	}

	MbTextDescription {
		id: description
		anchors {
			left: parent.left; leftMargin: styleItem.marginDefault
			verticalCenter: parent.verticalCenter
		}
		opacity: greyed ? styleItem.opacityDisabled : styleItem.opacityEnabled
	}

	Rectangle {
		id: tag
		color: "#ddd"
		radius: 3
		height: valueText.height + 6
		width: valueText.width + 10
		anchors {
			right: parent.right; rightMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}
		visible: valueText.text != "" && valueText.text != " "
	}

	MbTextValue {
		id: valueText
		anchors {
			right: root.right; rightMargin: styleItem.marginDefault + 5
			verticalCenter: parent.verticalCenter
		}

		text: getText(root.value)
		opacity: greyed ? styleItem.opacityDisabled : styleItem.opacityEnabled
	}

	MbIcon {
		id: statusIcon
		iconId: root.iconId
		anchors {
			right: root.right; rightMargin: styleItem.marginDefault
			verticalCenter: parent.verticalCenter
		}
	}

	Component {
		id: mbPageFactory
		MbPage {
			id: optionPage
			title: root.description
			leftIcon: "icon-toolbar-cancel"
			leftText: ""
			rightIcon: "icon-toolbar-ok"
			rightText: ""
			model: VisualItemModel {}
		}
	}

	Component {
		id: mbCheckBoxFactory

		MbCheckBox {
			property variant value
			property bool readonly
			property variant parentPage;
			property bool editPassword: false
			property string password: ""
			property bool isCurrentItem: ListView.isCurrentItem
			height: editPassword ? passwordBox.height : defaultHeight
			onIsCurrentItemChanged: if (!isCurrentItem) editPassword = false
			writeAccessLevel: root.writeAccessLevel
			show: !readonly || parentPage.value === value
			checked: parentPage.value === value

			onEditPasswordChanged: {
				if (editPassword)
					return

				if (passwordBox.text == password) {
					state = 'animate'
					valueSelected(value)
				} else {
					pageStack.pop()
				}
			}

			Keys.onSpacePressed: selected()
			Keys.onReturnPressed: selected()
			Keys.onEscapePressed: pageStack.pop()

			Keys.onUpPressed: {
				if (magicKeys) {
					if (upCount < 5) ++upCount;
					if (downCount > 0) upCount = 0
					downCount = 0;
				}
				event.accepted = false
			}

			Keys.onDownPressed: {
				if (magicKeys) {
					if (downCount < 5) ++downCount;
					if (upCount == 5 && downCount == 5) {
						valueSelected(User.AccessService)
						upCount = 0;
					}
				}
				event.accepted = false
			}

			function selected() {
				if (password == "") {
					state = 'animate';
					valueSelected(value);
				} else {
					editPassword = true;
					passwordBox.edit()
				}
			}

			MbEditBox {
				id: passwordBox
				width: root.width // needed to prevent a binding loop on width
				description: qsTr("Password")
				anchors.bottom: parent.bottom
				matchString: " ABCDEFGHIJKLMNOPQRSTUVWXYZ"
				show: editPassword
				onEditModeChanged: editPassword = editMode
				writeAccessLevel: root.writeAccessLevel
			}

			data: MouseArea {
				anchors.fill: parent;
				onClicked: { select(); selected() }
			}
		}
	}

	VBusItem {
		id: vItem
	}

	function getText(value)
	{
		for (var i = 0; i < possibleValues.length; i++)
		{
			var option = possibleValues[i];
			if (option.value === value)
				return option.description;
		}
		return unknownOptionText
	}

	function valueSelected(value)
	{
		// this is animation -> ignore spurious events
		if (state != "")
			return;

		// the pagestack is animation -> ignore spurious events
		if (pageStack.currentPage != root.childPage || childPage.status !== PageStatus.Active)
			return

		state = "closing"
		if (root.valid) {
			if (vItem.value !== value) {
				vItem.setValue(value)
				root.showOldSelection = false
			}
		} else {
			if (root.localValue !== value) {
				root.localValue = value
				root.showOldSelection = false
			}
		}
	}

	function edit() {
		if (root.readonly || !pageStack.currentPage.active)
			return

		root.childPage = pageStack.push(mbPageFactory);

		for (var i = 0; i < possibleValues.length; i++)
		{
			var option = possibleValues[i];
			var mbCheckbox = mbCheckBoxFactory.createObject(this, {
									"description": option.description,
									"value": option.value,
									"parentPage": root,
									"readonly" : option.readonly,
									"password" : option.password} )

			childPage.model.append(mbCheckbox)

			if (root.value === option.value) {
				childPage.currentIndex = i;
				childPage.listview.positionViewAtIndex(i, ListView.Contain)
			}
		}


	}

	transitions: [
		Transition {
			to: "closing"
			SequentialAnimation {
				PauseAnimation { duration: 1000 }
				ScriptAction {
					script: { pageStack.pop(); state = "" }
				}
			}
		}
	]

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked: { select(); edit();}
	}
}
