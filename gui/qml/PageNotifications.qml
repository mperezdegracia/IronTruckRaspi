import QtQuick 1.1
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Notifications")
	model: NotificationCenter.notifications

	delegate: MbItemNotification {
		active: model.modelData.active
		type: model.modelData.typeAsString
		devicename: model.modelData.serviceName
		date: Qt.formatDateTime(model.modelData.dateTime, "yyyy-MM-dd hh:mm")
		description: model.modelData.description
		value: model.modelData.value
		rightIcon: NotificationCenter.alert ? "icon-toolbar-ok" : "icon-toolbar-menu"
		cornerMark: NotificationCenter.alert
		writeAccessLevel: User.AccessUser

		function edit()
		{
			NotificationCenter.acknowledgedAll()
		}
	}

	MbItemText {
		height: 70
		visible: NotificationCenter.notifications.length === 0
		text: qsTr("No notifications")
		style: MbStyle {
			isCurrentItem: true
		}
	}
}
