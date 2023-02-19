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
import "UIConstants.js" as UI

SliderTemplate {
	id: slider

	property Style platformStyle: SliderStyle{}

	opacity: enabled ? UI.OPACITY_ENABLED : UI.OPACITY_DISABLED

	__handleItem: Rectangle {
		height: 20
		width: 20
		radius: width * 0.5
		border.width: 2
		smooth: true
		border.color: !inverted ? "#777" : "#fff"
	}

	__grooveItem: Rectangle {
			height: 3
			color:"#ddd"
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				right: parent.right
			}
	}

	__valueTrackItem: Rectangle {
		height: 6
		color: "#777"
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			right: parent.right
		}
	}

	__valueIndicatorItem: BorderImage {
		id: indicatorBackground
		source: platformStyle.valueBackground
		border { left: 12; top: 12; right: 12; bottom: 12 }

		width: label.width + 28
		height: 40

		Image {
			id: arrow
		}

		state: slider.valueIndicatorPosition
		states: [
			State {
				name: "Top"
				PropertyChanges {
					target: arrow
					source: platformStyle.labelArrowDown
				}
				AnchorChanges {
					target: arrow
					anchors.top: parent.bottom
					anchors.horizontalCenter: parent.horizontalCenter
				}
			},
			State {
				name: "Bottom"
				PropertyChanges {
					target: arrow
					source: platformStyle.labelArrowUp
				}
				AnchorChanges {
					target: arrow
					anchors.bottom: parent.top
					anchors.horizontalCenter: parent.horizontalCenter
				}
				AnchorChanges {
					target: indicatorBackground
				}
			},
			State {
				name: "Left"
				PropertyChanges {
					target: arrow
					source: platformStyle.labelArrowLeft
				}
				AnchorChanges {
					target: arrow
					anchors.left: parent.right
					anchors.verticalCenter: parent.verticalCenter
				}
			},
			State {
				name: "Right"
				PropertyChanges {
					target: arrow
					source: platformStyle.labelArrowRight
				}
				AnchorChanges {
					target: arrow
					anchors.right: parent.left
					anchors.verticalCenter: parent.verticalCenter
				}
			}
		]

		Text {
			id: label
			anchors.centerIn: parent
			text: slider.valueIndicatorText
			color: slider.platformStyle.textColor
			font.pixelSize: slider.platformStyle.fontPixelSize
			font.family: slider.platformStyle.fontFamily
		}

		// Native libmeegotouch slider value indicator pops up 100ms after pressing
		// the handle... but hiding happens without delay.
		visible: slider.valueIndicatorVisible && slider.pressed
		Behavior on visible {
			enabled: !indicatorBackground.visible
			PropertyAnimation {
				duration: 100
			}
		}
	}

	function up()
	{
		value += stepSize
	}

	function down()
	{
		value -= stepSize
	}
}