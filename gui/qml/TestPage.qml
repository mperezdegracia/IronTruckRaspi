import QtQuick 1.1

StackPage {
	focus: active

	Keys.onPressed: {
		pageStack.pop();
		event.accepted = true
	}

	//TestLines {}
	TestOverviewConnection {}
}
