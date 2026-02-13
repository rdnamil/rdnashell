/*------------------------------
--- Lockscreen.qml by andrel ---
------------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.controls as Ctrl

Singleton { id: root
	property list<var> wallpapers

	signal lock()
	signal unlock()

	function init() {}

	Ctrl.LockContext { id: context; onUnlocked: { lock.locked = false; root.unlock(); }}

	WlSessionLock { id: lock
		surface: WlSessionLockSurface { id: surface
			Ctrl.LockSurface {
				context: context
				wallpaper: root.wallpapers.find(w => w.display === surface.screen.name).path
			}
		}
	}

	Variants {
		model: Quickshell.screens
		delegate: PanelWindow { id: window
			required property var modelData

			visible: false
			screen: modelData
			anchors { left: true; right: true; top: true; bottom: true; }
			exclusiveZone: -1
			mask: Region {}
			color: "transparent"

			ShaderEffectSource { id: source
				anchors.fill: parent
				sourceItem: Ctrl.LockSurface {
					context: context
					wallpaper: root.wallpapers.find(w => w.display === window.screen.name)?.path || ''
					width: window.width; height: window.height;
				}
				transform: Translate { id: trans; }
			}

			ParallelAnimation { id: anim
				onStarted: window.visible = true;
				onFinished: lock.locked = true;

				NumberAnimation {
					target: source; property: "opacity";
					from: 0.0; to: 1.0;
					duration: 500; easing.type: Easing.OutCirc;
				}
				NumberAnimation {
					target: trans; property: "y";
					from: -window.height; to: 0;
					duration: 500; easing.type: Easing.OutCirc;
				}
			}

			Connections {
				target: root

				function onLock() { anim.start(); }
				function onUnlock() { window.visible = false; }
			}
		}
	}

	Process { id: getWallpaper
		running: true
		command: ['swww', 'query']
		stdout: StdioCollector {
			onStreamFinished: {
				var ws = text.trim().split('\n');

				root.wallpapers = [];

				for (let w of ws) {
					const parts = w.match(/^:\s*(\S+):\s*([^,]+),\s*scale:\s*(\d+),\s*currently displaying:\s*(\w+):\s*(.+)$/);

					if (!parts) continue;

					root.wallpapers.push({
						display: parts[1],
						resolution: parts[2],
						scale: parts[3],
						type: parts[4],
						path: parts[5]
					});
				}
			}
		}
	}

	IpcHandler {
		target: "lockscreen"
		function lock(): void { root.lock(); }
		function unlock(): void { context.unlocked(); }
	}
}
