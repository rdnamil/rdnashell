/*-------------------------
--- shell.qml by andrel ---
-------------------------*/

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
			NiriWorkspaces {}
		]
		right: [
			SystemTray {},
			ColourPicker {},
			Weather {},
			DateTime {},
			PowerManagement {},
			NotificationTray {}
		]
	}

	NotificationToasts {}

	Component.onCompleted: {
		Service.ShellUtils.init();
		Service.Brightness.init();
		Settings.init();
		AppLauncher.init();
	}
}
