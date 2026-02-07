pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.styles as Style
import qs.components
import "../globals.js" as Globals

Singleton { id: root
	readonly property Item osd: Row {
		spacing: Globals.Controls.spacing *2

		IconImage {
			implicitSize: Globals.Controls.iconSize
			source: {
				const b = root.screen.current /root.screen.max

				if (b == 0) return Quickshell.iconPath("display-brightness-off-symbolic");
				else if (b < (1 /3)) return Quickshell.iconPath("display-brightness-low-symbolic");
				else if (b < (2 /3)) return Quickshell.iconPath("display-brightness-medium-symbolic");
				else return Quickshell.iconPath("display-brightness-high-symbolic");
			}
		}

		Style.Slider {
			anchors.verticalCenter: parent.verticalCenter
			width: 100
			height: Globals.Controls.iconSize -2
			value: root.screen.current /root.screen.max
		}
	}

	readonly property QtObject screen: QtObject {
		property int max
		property int current
	}

	function init() {}

	// get the maximum brightness value
	Process {
		running: true
		command: ["brightnessctl", "max"]
		stdout: StdioCollector {
			onStreamFinished: {
				root.screen.max = parseInt(text);
			}
		}
	}

	// get the current brightness value
	Process { id: getCurrentBrightness
		running: true
		command: ["brightnessctl", "get"]
		stdout: StdioCollector {
			onStreamFinished: {
				root.screen.current = parseInt(text);
			}
		}
	}

	// listen for backlight events and update the current brightness on UDEV event
	Process {
		running: true
		command: ["udevadm", "monitor", "--subsystem-match=backlight"]
		stdout: SplitParser {
			splitMarker: "UDEV"
			onRead: {
				getCurrentBrightness.running = true;
				OSD.display(root.osd);
			}
		}
	}
}
