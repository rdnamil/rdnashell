/*------------------------------
--- ShellUtils.qml by andrel ---
------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

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

	FileView { id: pinView
		path: Qt.resolvedUrl("../components/pins.json")

		JsonAdapter {
			property list<string> pins
		}
	}

	Process { id: getUserFullName
		property string userFullName: ''

		running: true
		command: ['sh', '-c', 'getent passwd "$(whoami)" | cut -d: -f5 | cut -d, -f1']
		stdout: StdioCollector { onStreamFinished: getUserFullName.userFullName = text; }
	}
}
