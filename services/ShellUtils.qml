pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	function init() {}

	// reload Qs on changes to Globals
	FileView {
		path: Qt.resolvedUrl("../globals.js")
		watchChanges: true
		onFileChanged: Quickshell.reload(false);
	}
}
