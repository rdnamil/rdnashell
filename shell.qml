/*-------------------------
--- shell.qml by andrel ---
-------------------------*/

import QtQuick
import Quickshell
import qs.components
import qs.widgets
import qs.services as Service

ShellRoot {
	Bar {
		left: [
			Network {},
			Bluetooth {},
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
	Dock {}
	NotificationToasts {}

	Component.onCompleted: {
		Service.ShellUtils.init();
		Settings.init();
		Lockscreen.init();
		AppLauncher.init();
		Service.Idle.init(
			300 // timeout to idle in seconds
		);
		Service.Brightness.init(); // uses brightnessctl
		Service.Sunsetr.init(
			3500, // temperature in K
			95, // gamma (0-100)
			true, // enable geo located sunset/sunrise times (static times will be ignored if 'true')
			"19:00", // static start time
			"7:00" // static end time
		);
	}
}
