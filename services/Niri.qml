/*------------------------
--- Niri.qml by andrel ---
------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	property var workspaces: null
	property var windows: null

	signal colourPicked(color colour)

	function pickColour() { getColour.running = true; }

	Process {
		running: true
		command: ['niri', 'msg', 'event-stream']
		stdout: SplitParser {
			onRead: data => {
				if (data.startsWith("Workspace")) getWorkspaces.running = true;
				if (data.startsWith("Window")) getWindows.running = true;
			}
		}
	}

	Process { id: getWorkspaces
		running: true
		command: ['niri', 'msg', '--json', 'workspaces']
		stdout: StdioCollector {
			onStreamFinished: root.workspaces = JSON.parse(text);
		}
	}

	Process { id: getWindows
		running: true
		command: ['niri', 'msg', '--json', 'windows']
		stdout: StdioCollector {
			onStreamFinished: root.windows = JSON.parse(text);
		}
	}

	Process { id: getColour
		command: ['niri', 'msg', '--json', 'pick-color']
		stdout: StdioCollector {
			onStreamFinished: {
				const c = JSON.parse(text);
				if (c) root.colourPicked(Qt.rgba(c.rgb[0], c.rgb[1] , c.rgb[2], 1.0));
			}
		}
	}
}
