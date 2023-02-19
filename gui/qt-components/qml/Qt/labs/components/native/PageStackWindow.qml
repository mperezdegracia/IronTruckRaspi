/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**	 notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**	 notice, this list of conditions and the following disclaimer in
**	 the documentation and/or other materials provided with the
**	 distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**	 the names of its contributors may be used to endorse or promote
**	 products derived from this software without specific prior written
**	 permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 1.1
import Qt.labs.components.native 1.0

Window {
	id: window

	property bool showStatusBar: pageStack.currentPage ? pageStack.currentPage.showStatusBar : true
	property bool showToolBar: pageStack.currentPage ? pageStack.currentPage.showToolBar : true
	property bool showAlert: false
	property variant initialPage
	property alias pageStack: stack
	property Style platformStyle: PageStackWindowStyle{}
	property alias platformToolBarHeight: toolBar.height // read-only
	property alias internetConnected: statusBar.internetConnected
	property alias gpsConnected: statusBar.gpsConnected

	property alias statusBarBottom: statusBar.bottom
	//Deprecated, TODO Remove this on w13
	property alias style: window.platformStyle

	//private api
	property int __statusBarHeight: showStatusBar ? statusBar.height : 0

	objectName: "pageStackWindow"

	StatusBar {
		id: statusBar
		anchors.top: parent.top
		width: parent.width
		showStatusBar: window.showStatusBar
		showAlert: window.showAlert
	}

	onOrientationChangeStarted: {
		statusBar.orientation = screen.currentOrientation
	}

	Item {
		objectName: "appWindowContent"
		width: parent.width
		anchors.top: statusBar.bottom
		anchors.bottom: parent.bottom

		// content area
		Item {
			id: contentArea
			anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom; }
			anchors.bottomMargin: toolBar.visible || (toolBar.opacity==1)? toolBar.height : 0

			PageStack {
				id: stack
				anchors.fill: parent
				toolBar: toolBar
			}
		}

		ToolBar {
			id: toolBar
			anchors.bottom: parent.bottom
			privateVisibility: window.showToolBar ? ToolBarVisibility.Visible : ToolBarVisibility.Hidden
		}
	}

	// event preventer when page transition is active
	MouseArea {
		anchors.fill: parent
		enabled: pageStack.busy
	}

	Component.onCompleted: {
		if (initialPage) pageStack.push(initialPage);
	}
}
