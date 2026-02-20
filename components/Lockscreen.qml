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
				screen: surface.screen
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
			WlrLayershell.layer: WlrLayer.Overlay
			mask: Region {}
			color: "transparent"

			ShaderEffectSource { id: source
				anchors.fill: parent
				sourceItem: Ctrl.LockSurface { id: sourceItem
					context: context
					width: window.width; height: window.height;
				}
				transform: Translate { id: trans; }
			}

			ParallelAnimation { id: lockAnim
				onStarted: window.visible = true;
				onFinished: {
					lock.locked = true;
					sourceItem.state = Ctrl.LockSurface.State.SignIn;
				}

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

			ParallelAnimation { id: unlockAnim
				onFinished: {
					window.visible = false;
					sourceItem.state = Ctrl.LockSurface.State.Cover;
				}

				NumberAnimation {
					target: source; property: "opacity";
					to: 0.0; from: 1.0;
					duration: 500; easing.type: Easing.InCirc;
				}
				NumberAnimation {
					target: trans; property: "y";
					to: -window.height; from: 0;
					duration: 500; easing.type: Easing.OutCirc;
				}
			}

			Connections {
				target: root

				function onLock() { lockAnim.start(); }
				function onUnlock() { unlockAnim.start(); }
			}
		}
	}

	IpcHandler {
		target: "lockscreen"
		function lock(): void { root.lock(); }
		function unlock(): void { context.unlocked(); }
	}
}
