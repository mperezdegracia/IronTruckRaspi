import QtQuick 1.1
import com.victron.velib 1.0

MbPage {
	id: root

	property string bindPrefix: "dbus"

	title: bindPrefix

	model: VeQuickItemModelBuilder {
		uids: [bindPrefix]
		Component.onCompleted: {
			listview.currentIndex = 0
		}
	}

	delegate: MbSubMenu {
		id: submenu

		description: id
		item.bind: model.uid

		function open()
		{
			var component = Qt.createComponent("PageDebugVeQItems.qml");
			var page = component.createObject(submenu, {"bindPrefix": uid})
			pageStack.push(page)
		}
	}
}
