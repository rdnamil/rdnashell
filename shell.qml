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
			Caffeine {},
			Redeye {},
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
		Service.Sunsetr.init(
			3500, // temperature in K
			95, // gamma (0-100)
			true, // enable geo located sunset/sunrise times (static times will be ignored if 'true')
			"19:00", // static start time
			"7:00" // static end time
		);
	}
}
