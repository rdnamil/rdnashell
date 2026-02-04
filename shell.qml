//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.components
import qs.widgets
import qs.services as Service

ShellRoot { id: root
	Bar {
		left: [
			Audio {},
			MusicPlayer {}
		]
		centre: [
		]
		right: [
			SystemTray {},
			Weather {},
			DateTime {},
			PowerManagement {},
			NotificationTray {}
		]
	}

	NotificationToasts {}

	Component.onCompleted: {
		Service.ShellUtils.init();
		Service.Settings.init();
		Service.AppLauncher.init();
	}
}
