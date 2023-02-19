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
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
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

/// Helper code that is needed by ToolBarLayout.

var connectedItems = [];

// Find item in an array
function contains(container, obj) {
	for (var i = 0 ; i < container.length; i++) {
		if (container[i] == obj)
			return true;
	}
	return false
}

// Remove item from an array
function remove(container, obj)
{
	for (var i = 0 ; i < container.length ; i++ )
		if (container[i] == obj)
			container.splice(i,1);
}

// Helper function to give us the sender id on slots
// This is needed to remove connectens on a reparent
Function.prototype.bind = function() {
	var func = this;
	var thisObject = arguments[0];
	var args = Array.prototype.slice.call(arguments, 1);
	return function() {
		return func.apply(thisObject, args);
	}
}

// Called whenever a child is added or removed in the toolbar
function childrenChanged() {
	for (var i = 0; i < children.length; i++) {
		if (!contains(connectedItems, children[i])) {
			connectedItems.push(children[i]);
			children[i].visibleChanged.connect(layout);
			children[i].parentChanged.connect(cleanup.bind(children[i]));
		}
	}
}

// Disconnects signals connected by this layout
function cleanup() {
	remove(connectedItems, this);
	this.visibleChanged.disconnect(layout);
	this.parentChanged.disconnect(arguments.callee);
}

// Main layout function
function layout() {

	if (parent === null || width === 0)
		return;

/*
	var i;
	var items = new Array();          // Keep track of visible items
	var expandingItems = new Array(); // Keep track of expandingItems for tabs
	var widthOthers = 0;

	for (i = 0; i < children.length; i++) {
		if (children[i].visible) {
			items.push(children[i])

			// Center all items vertically
			items[0].y = (function() {return height / 2 - items[0].height / 2})
			// Find out which items are expanding
			if (children[i].__expanding) {
				expandingItems.push(children[i])
			} else {
				// Calculate the space that fixed size items take
				widthOthers += children[i].width;
			}
		}
	}

	if (items.length === 0)
		return;
	*/
	if (children.length >= 1) {
		children[0].anchors.verticalCenter = virticalCenter
		children[0].anchors.left = left;
		children[0].anchors.leftMargin = 60
	}

}
