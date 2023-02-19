import QtQuick 1.1
import Qt.labs.components.native 1.0
import "utils.js" as Utils

StackPage {
	id: listPage

	property alias model: browser.model
	property alias delegate: browser.delegate
	property alias currentIndex: browser.currentIndex
	property alias listview: browser
	property variant summary
	property int _visibleIndex: browser.currentIndex
	property int _visibleCount: countVisibleItems()
	property bool _lastItemReached
	property bool _firstItemReached

	property string defaultLeftIcon: "icon-toolbar-pages"
	property string defaultLeftText: qsTr("Pages")
	property string defaultRightIcon: "icon-toolbar-menu"
	property string defaultRightText: qsTr("Menu")

	tools: mbTools
	leftIcon: (browser.currentItem && browser.currentItem.leftIcon ? browser.currentItem.leftIcon : defaultLeftIcon)
	leftText: browser.currentItem && browser.currentItem.leftText !== "default" ? browser.currentItem.leftText : defaultLeftText
	rightIcon: (browser.currentItem && browser.currentItem.rightIcon ? browser.currentItem.rightIcon : defaultRightIcon)
	rightText:  browser.currentItem && browser.currentItem.rightText !== "default" ? browser.currentItem.rightText : defaultRightText

	showStatusBar: true

	onActiveChanged: {
		if (active) {
			scrollIndicator = getScrollIndicator()
			listview.positionViewAtIndex(listview.currentIndex, ListView.Visible)
		}
	}

	ListView {
		id: browser
		anchors.fill: parent
		focus: listPage.status === PageStatus.Active || listPage.status === PageStatus.Activating
		snapMode: ListView.SnapOneItem
		clip: true
		cacheBuffer: height + 1 // QTBUG-61537

		Component.onCompleted: {
			currentIndex = firstVisibleItem()
			if (currentIndex !== -1)
				positionViewAtIndex(currentIndex, ListView.Beginning)
		}

		Keys.onLeftPressed: if (listPage.status === PageStatus.Active && pageStack.depth > 1) pageStack.pop()

		Keys.onUpPressed: {
			if (_visibleIndex > 0) {
				_visibleIndex--
			}
			event.accepted = false
		}

		Keys.onDownPressed: {
			if (_visibleIndex < _visibleCount - 1) {
				_visibleIndex++
			}
			event.accepted = false
		}

		onCurrentItemChanged: scrollIndicator = getScrollIndicator()
	}

	/* As some items are not visible (show = false) a extra work is necessary to implement scroll indicators. We need to iterate the
	model to count visible items only. We also need to keep the count of current index to get the index related to visible items.
	The correct way to implement the scroll indicator should be using "atYEnd" property, but does not work correctly when scrolling
	to the end holding down the "down" key, and is also not usable when the listview have non-visible items.*/

	function getScrollIndicator() {
		var up = false
		var down = false
		var updown = false
		var icon = ""
		var count = _visibleCount
		var index = _visibleIndex

		if (count > 6) {
			if (index == count - 1)
				_lastItemReached = true

			if (index < count - 6 && _lastItemReached)
				_lastItemReached = false

			if (index == 0)
				_firstItemReached = true

			if (index > 5)
				_firstItemReached = false

			down = !_lastItemReached
			up = !_firstItemReached
			updown = up && down
			icon = updown ? "icon-toolbar-arrow-up-down" :
					down ? "icon-toolbar-arrow-down" :
					up ? "icon-toolbar-arrow-up" :
					""
		}

		return icon
	}

	function countVisibleItems()
	{
		// When model is a ListModel all items are visible
		if (Utils.qmltypeof(browser.model, "QDeclarativeListModel"))
			return browser.model.count;

		var count = 0

		if (browser.model && browser.model.children !== undefined)
			for (var i = 0; i < browser.model.count; i++) {
				count += browser.model.children[i].show ? 1: 0
			}
		else
			count = browser.count

		return count
	}

	function firstVisibleItem()
	{
		// Return 0 as first visible item for models based on ListModel
		// instead of VisualItemModel like the timezone selection page.
		// ListModel doesn't have a "show" property and are always visible
		// on the list

		if (Utils.qmltypeof(browser.model, "QDeclarativeListModel"))
			return 0;

		if (browser.model && browser.model.children !== undefined)
			for (var i = 0; i < browser.model.count; i++) {
				if (browser.model.children[i].show)
					return i
			}
		return -1;
	}
}
