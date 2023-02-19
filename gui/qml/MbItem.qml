import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

/*
 * The MbItem serves as a base object for Items which can be placed in
 * the menubrowser (Mb), see MbPage. It makes adds default functions for
 * for key behavior, icons, subpage navigtation and only shows a default
 * background. Any derived mb Item can fill it to its desire.
 */
Item {
	id: root
	width: (parent ? parent.width : 0)
	height: defaultHeight
	property int defaultHeight: style.itemHeight

	// define icons for editmode
	property bool editMode
	property string leftIcon: editMode ? "icon-toolbar-cancel" : ""
	property string leftText: editMode ? "" : "default"
	property string rightIcon: editMode ? "icon-toolbar-ok" : ""
	property string rightText: editMode ? "" : "default"

	property MbStyle style: MbStyle { isCurrentItem: root.ListView.isCurrentItem }

	// Navigation for subpages
	property bool hasSubpage: subpage !== undefined
	property variant subpage

	property bool cornerMark: false

	property int writeAccessLevel: User.AccessInstaller
	property bool userHasWriteAccess: user.accessLevel >= writeAccessLevel
	property bool editable: true

	// NOTE: this is added to our 4.8 qt version. Uncomment this line to run on a
	// vanilla QT. But optional rows are then always visible.
	//property bool show

	signal selected
	signal clicked

	function open() {
		if (pageStack.currentPage.active && hasSubpage)
			pageStack.push(subpage);
	}

	function edit() {
	}

	function select() {
		if (!pageStack)
			return
		// Calling VisualItemModel when the model is not a VisualItemModel
		// allways returns 0 breaking the use of mouse for navigate and
		// edit settings when the model is a ListModel. Using "index" when
		// model is ListView fix the issue.
		if (Utils.qmltypeof(pageStack.currentPage.model, "QDeclarativeListModel")){
			pageStack.currentPage.currentIndex = index
		} else {
			pageStack.currentPage.currentIndex = root.VisualItemModel.index
		}
		if (!userHasWriteAccess && !hasSubpage && editable)
			 toast.createToast(qsTr("Setting locked for \"user\" access level."), 3000, "icon-lock-active");
		root.selected()
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: style.backgroundColor
	}

	MbIcon {
		id: cornerMarkIcon

		iconId: "icon-items-corner" + (root.ListView.isCurrentItem ? "-active" : "")
		visible: cornerMark
		anchors {
			right: parent.right; rightMargin: 1
			bottom: bottomBorder.top; bottomMargin: 1
		}
	}

	Rectangle {
		id: bottomBorder
		width: root.width
		height: 1
		color: style.borderColor
		anchors.bottom: root.bottom
	}

	Keys.onRightPressed: {
		if (userHasWriteAccess)
			root.clicked()
		if (!userHasWriteAccess && !hasSubpage)
			 toast.createToast(qsTr("Setting locked due to access level."), 3000, "icon-lock-active");
		else
			open()
	}

	Keys.onSpacePressed: {
		if (userHasWriteAccess)
			root.clicked()
		if (!userHasWriteAccess && !hasSubpage && editable)
			toast.createToast(qsTr("Setting locked due to access level."), 3000, "icon-lock-active");
		else
			pageStack.currentPage.active && hasSubpage ? open() : edit()
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked: {
			if (hasSubpage) {
				select()
				open()
			} else {
				if (!root.ListView.isCurrentItem)
					select()
				else {
					root.clicked()
					edit()
				}
			}
		}
	}
}
