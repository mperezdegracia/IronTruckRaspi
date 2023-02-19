import QtQuick 1.1
import Qt.labs.components.native 1.0

Page {
	property bool active: status === PageStatus.Active

	// properties of the default toolbar, iow with tools: mbTools
	// A page can have its own toolbar if needed.
	property string leftIcon: "icon-toolbar-pages"
	property string leftText: qsTr("Pages")
	property string rightIcon: "icon-toolbar-menu"
	property string rightText: qsTr("Menu")
	property string scrollIndicator
}
