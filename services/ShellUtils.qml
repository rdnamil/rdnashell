/*------------------------------
--- ShellUtils.qml by andrel ---
------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.widgets as Widget

Singleton { id: root
	readonly property alias pinView: pinView
	readonly property string userFullName: getUserFullName.userFullName

	function init() {}

	// reload Qs on changes to Globals
	FileView {
		path: Qt.resolvedUrl("../globals.js")
		watchChanges: true
		onFileChanged: Quickshell.reload(false);
	}

	FileView {
		path: `${Quickshell.env("HOME")}/.local/share/applications/rdnashell.desktop`
		onLoadFailed: setData(`[Desktop Entry]
Name=Rdnashell Settings
Comment=Customize the shell
Exec=qs ipc call settings launch
Icon=preferences-desktop-theme
Terminal=false
Type=Application
Categories=Settings;`);
	}

	FileView { id: pinView
		function open(index) {
			DesktopEntries.applications.values
				.find(pinView.adapter.pins[index])
				.execute();
		}

		path: Qt.resolvedUrl("../components/pins.json")

		JsonAdapter {
			property list<string> pins
		}
	}

	Widget.Power { id: power; height: -1; }

	Process { id: getUserFullName
		property string userFullName: ''

		running: true
		command: ['sh', '-c', 'getent passwd "$(whoami)" | cut -d: -f5 | cut -d, -f1']
		stdout: StdioCollector { onStreamFinished: getUserFullName.userFullName = text; }
	}

	IpcHandler {
		target: "utils"

		function reload(): void { Quickshell.reload(false); }
		function showPowerMenu(): void { power.clicked(null); }
	}
}
