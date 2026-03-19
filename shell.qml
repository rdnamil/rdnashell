/*-------------------------
--- shell.qml by andrel ---
-------------------------*/

//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.components
import qs.widgets
import qs.services as Service

ShellRoot {
	Bar {
		height: 38 // set the height of the bar
		anchors: Edges.Top // anchor points **note** only top or bottom edges accepted for now
		left: [
 			Network {},
			Bluetooth {},
			Audio {}
		]
		centre: [
			NiriWorkspaces {
				names: ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'] // workspace names (leave blank to default to workspace index)
			}
		]
		right: [
			SystemTray {},
			Yay {
				notifyOn: 25 // number of updates before notifying
				updateCommmand: ['ghostty', '-e', 'yay'] // command to run to update
			},
			ColourPicker {},
			Caffeine {},
			Redeye {},
			Weather {},
			DateTime {
				stack: false
			},
			PowerManagement {},
			NotificationTray {}
		]
	}
	Dock {
		widgets: [
			Spacer {},
			StartMenu {
				fileManager: "thunar" // set file manager used to open shortcuts (unset to use system default)
				centreHorizontally: true // whether to centre the menu horizontally on the display
			},
			Windows {
				hideLabels: true // show only the window app icon
				labelMaxWidth: 100 // set the maximum width of the label (has no effect if labels are hidden)
			},
			Separator {
				visible: Service.MPlayer.active
			},
			MiniPlayer {},
			Spacer {}
		]
	}
	NotificationToasts {
		anchors: Edges.Left | Edges.Right // anchor points (edges left+right will centre)
		displays: ["DP-1"] // outputs to display on (empty list will display on all outputs)
	}

	// services to start up
	Component.onCompleted: {
		Service.ShellUtils.init();
		Settings.init();
		Lockscreen.init();
		AppLauncher.init();
		Service.Idle.init(
			300 // timeout to idle in seconds
		);
		// Service.Brightness.init(); // uses brightnessctl
		Service.Sunsetr.init(
			3500, // temperature in K
			95, // gamma (0-100)
			true, // enable geo located sunset/sunrise times (static times will be ignored if 'true')
			"19:00", // static start time
			"7:00" // static end time
		);
	}
}
