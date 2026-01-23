import QtQuick
import Quickshell
import qs.components
import qs.widgets
import qs.services

ShellRoot { id: root
	Bar {
		left: [
			Test {}
		]
		centre: [
			Test {}
		]
		right: [
			NotificationTray {},
		]
	}
	NotificationToasts {}

	Component.onCompleted: {
		ShellUtils.init();
	}
}
