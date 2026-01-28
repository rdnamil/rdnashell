import QtQuick
import Quickshell
import qs.components
import qs.widgets
import qs.services
import qs.controls

ShellRoot { id: root
	Bar {
		left: [
			Test {}
		]
		centre: [
			// NotificationTray {},
			Test {},
			MusicPlayer {},
			Test {}
		]
		right: [

			Test {}
		]
	}
	// NotificationToasts {}

	Component.onCompleted: {
		ShellUtils.init();
	}
}
