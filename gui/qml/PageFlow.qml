import QtQuick 1.1
import Qt.labs.components.native 1.0

StackPage {
	id: root
	property bool autoSelect: true
	property bool flowing: true
	property bool moving: false
	property bool maximized: !flowing && !moving && active
	property variant currentItem
	property alias model: pathView.model
	property alias currentIndex: pathView.currentIndex
	property int defaultIndex: 0

	visible: false
	tools: currentItem !== undefined && currentItem.mbTools !== undefined ? currentItem.mbTools : mbTools
	showToolBar: currentItem !== undefined && currentItem.showToolBar && !flowing

	Keys.onReturnPressed: if (active) pageStack.pop(); // Go to previous page on the menu
	// Keys.onUpPressed: if (flowing) { autoSelect = !autoSelect; resetAutoselect() }
	Keys.onSpacePressed: if (flowing) switchMode()
	Keys.onEscapePressed: if (flowing) pathView.incrementCurrentIndex(); else switchMode();
	Keys.onLeftPressed: if (flowing) pathView.decrementCurrentIndex();
	Keys.onRightPressed: if (flowing) pathView.incrementCurrentIndex();

	onCurrentItemChanged: resetAutoselect()
	onFlowingChanged: if (flowing) currentItem.status = PageStatus.Inactive


	// trigger a "maximize" animation after component completion
	Component.onCompleted: {
		resetAutoselect()
		currentIndex = defaultIndex
		flowing = false
	}

	// Since the overview themselves are no longer in the pagestack themselves,
	// handle state for them, to enable / disable keyhandling by the overview themself
	onMaximizedChanged: {
		if (currentItem !== undefined) {
			pathView.focus = true
			currentItem.status = maximized ? PageStatus.Active : PageStatus.Inactive
		}
	}

	function switchMode()
	{
		if (currentItem === undefined)
			return

		if (flowing) {
			flowing = false
		} else {
			flowing = true
			resetAutoselect();
		}
	}

	// Background image
	Image {
		source: "image://theme/pageflow-background"
		anchors.fill: parent
		visible: currentItem !== undefined ? currentItem.parent.scale !== 1 : true
	}

	Text {
		id: title
		font.pixelSize: 25
		height: flowing ? paintedHeight : 0
		text: root.currentItem !== undefined ? root.currentItem.title : ""
		color: "white"
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
		}

		Behavior on height {NumberAnimation {duration: 200; easing.type: Easing.InOutQuad}}
	}

	Component {
		id: pathDelegate

		Loader {
			property bool isCurrentItem: PathView.isCurrentItem
			source: pageSource
			width: 480
			height: 272
			scale: PathView.isCurrentItem && !flowing ? 1 : PathView.itemScale
			visible: PathView.isCurrentItem || flowing
			z: PathView.depth
			onXChanged: if (isCurrentItem) root.moving = x !== 0
			onSourceChanged: if (isCurrentItem) switchMode()

			// qml from 4.8 does not have currentItem yet, so manually keep track of it
			onLoaded: {
				item.visible = true
				if (isCurrentItem) root.currentItem = item
			}
			onIsCurrentItemChanged: {
				if (item != undefined && isCurrentItem) root.currentItem = item
			}

			// Perform animation only when the currentItem is scaling from/to fullscreen
			Behavior on scale {
				NumberAnimation {
					duration: isCurrentItem && scale >= 0.510 ? 200 : 0
				}
			}

			// White background for the page
			Rectangle {
				color: "white"
				anchors.fill: parent
				visible: parent.scale !== 1
			}

			// If the page is removed, jump to another page, scaling it twice performs a better
			// transition effect and keeps the focus
			Component.onDestruction: {
				if (!isCurrentItem)
					return
				switchMode()
				//currentItem = undefined
				if (pathView.currentIndex !== 0)
					pathView.decrementCurrentIndex()
				else
					pathView.incrementCurrentIndex()
			}
		}
	}

	Rectangle {
		id: timeLine
		height: 3
		width: 0
		visible: openTimer.running
		anchors {
			bottom: parent.bottom; bottomMargin: 35
			horizontalCenter: parent.horizontalCenter
		}

		Behavior on width { NumberAnimation {from: 0; to: 240; duration: openTimer.interval}}
	}

	function resetAutoselect()
	{
		if (autoSelect)
			openTimer.restart()
		else
			openTimer.stop()
	}

	Timer {
		id: openTimer
		interval: 2000
		running: autoSelect && flowing && root.active
		onTriggered: if (autoSelect && currentItem !== undefined) flowing = false
		onRunningChanged: timeLine.width = running ? 240 : 0
	}

	PathView {
		id: pathView
		anchors.fill: parent
		delegate: pathDelegate
		visible: parent.visible
		focus: root.active

		// When scaling down the page some borders dissapear, values set here are calculated
		// to keep the best looking possible.
		path: Path {
			startX: 240; startY: flowing ? 160 : 136
			PathAttribute { name: "itemScale"; value: 0.515 }
			PathAttribute { name: "depth"; value: 10 }
			PathQuad { x: 240; y: 49; controlX: 550; controlY: 75 }
			PathAttribute { name: "depth"; value: 0 }
			PathAttribute { name: "itemScale"; value: pathView.count % 2 == 0 ? 0.212 : 0.210}
			PathQuad { x: 240; y: flowing ? 160 : 136; controlX: -70; controlY: 75 }
		}
	}
}
