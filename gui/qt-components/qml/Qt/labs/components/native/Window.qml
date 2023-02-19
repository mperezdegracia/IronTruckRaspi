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

Item {
	id: root
	width: screen.displayWidth
	height: screen.displayHeight

	default property alias content: windowContent.data

	// Read only property true if window is in portrait
	property alias inPortrait: window.portrait

	objectName: "windowRoot"

	signal orientationChangeAboutToStart
	signal orientationChangeStarted
	signal orientationChangeFinished

	Item {
		id: window
		property bool portrait

		Component.onCompleted: {
			width = screen.platformWidth;
			height = screen.platformHeight;
		}

		anchors.centerIn : parent
		transform: Rotation { id: windowRotation;
								origin.x: 0;
								origin.y: 0;
								angle: 0
							}

		Item {
			id: windowContent
			width: parent.width
			height: parent.height - heightDelta

			// Used for resizing windowContent when virtual keyboard appears
			property int heightDelta: 0

			objectName: "windowContent"
			clip: true
		}

		state: screen.orientationString

		states: [
			State {
				name: "Landscape"
				PropertyChanges { target: window; rotation: screen.rotation; portrait: screen.isPortrait; explicit: true; }
				PropertyChanges { target: window; height: screen.platformHeight; width: screen.platformWidth; explicit: true; }
				PropertyChanges { target: windowRotation;
								  origin.x: root.height / 2;
								  origin.y: root.height / 2; }
			},
			State {
				name: "Portrait"
				PropertyChanges { target: window; rotation: screen.rotation; portrait: screen.isPortrait; explicit: true; }
				PropertyChanges { target: window; height: screen.platformHeight; width: screen.platformWidth; explicit: true; }
				PropertyChanges { target: windowRotation;
								  origin.x: root.height - root.width / 2;
								  origin.y: root.width / 2; }
			},
			State {
				name: "LandscapeInverted"
				PropertyChanges { target: window; rotation: screen.rotation; portrait: screen.isPortrait; explicit: true; }
				PropertyChanges { target: window; height: screen.platformHeight; width: screen.platformWidth; explicit: true; }
				PropertyChanges { target: windowRotation;
								  origin.x: root.height / 2;
								  origin.y: root.height / 2; }
				PropertyChanges { target: snapshot; anchors.leftMargin: 374; anchors.topMargin: 0 }
			},
			State {
				name: "PortraitInverted"
				PropertyChanges { target: window; rotation: screen.rotation; portrait: screen.isPortrait; explicit: true; }
				PropertyChanges { target: window; height: screen.platformHeight; width: screen.platformWidth; explicit: true; }
				PropertyChanges { target: windowRotation;
								  origin.x: root.height - root.width / 2;
								  origin.y: root.width / 2; }
				PropertyChanges { target: snapshot; anchors.leftMargin: 0; anchors.topMargin: 374 }
			}
		]

		focus: true
		Keys.onReleased: {
			if (event.key == Qt.Key_I && event.modifiers == Qt.AltModifier) {
				theme.inverted = !theme.inverted;
			}
			if (event.key == Qt.Key_E && event.modifiers == Qt.AltModifier) {
				if(screen.currentOrientation == Screen.Landscape) {
					screen.allowedOrientations = Screen.Portrait;
				} else if(screen.currentOrientation == Screen.Portrait) {
					screen.allowedOrientations = Screen.LandscapeInverted;
				} else if(screen.currentOrientation == Screen.LandscapeInverted) {
					screen.allowedOrientations = Screen.PortraitInverted;
				} else if(screen.currentOrientation == Screen.PortraitInverted) {
					screen.allowedOrientations = Screen.Landscape;
				}
			}
			if (event.key == Qt.Key_E && event.modifiers == Qt.ControlModifier ) {
				if(screen.currentOrientation == Screen.Portrait) {
					screen.allowedOrientations = Screen.Landscape;
				} else if(screen.currentOrientation == Screen.LandscapeInverted) {
					screen.allowedOrientations = Screen.Portrait;
				} else if(screen.currentOrientation == Screen.PortraitInverted) {
					screen.allowedOrientations = Screen.LandscapeInverted;
				} else if(screen.currentOrientation == Screen.Landscape) {
					screen.allowedOrientations = Screen.PortraitInverted;
				}
			}
		}
	}
}
