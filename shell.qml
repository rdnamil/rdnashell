import QtQuick
import Quickshell
import qs.components
import qs.widgets
import qs.services as Service

ShellRoot { id: root
	Bar {
		left: [
			MusicPlayer {}
		]
		centre: [
		]
		right: [
			DateTime {},
			PowerManagement {},
			NotificationTray {}
		]
	}

	NotificationToasts {}

	Component.onCompleted: {
		Service.ShellUtils.init();
		Service.AppLauncher.init();
	}
}
