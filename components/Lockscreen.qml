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
	signal lock(bool anim)
	signal unlock()

	function init() {}

	Ctrl.LockContext { id: context; onUnlocked: { lock.locked = false; root.unlock(); }}

	WlSessionLock { id: lock
		surface: WlSessionLockSurface { id: surface
			Ctrl.LockSurface { id: locksurface
				context: context
				screen: surface.screen

				IdleMonitor { id: monitor
					timeout: 10
					onIsIdleChanged: if (isIdle) {
						if (locksurface.state === Ctrl.LockSurface.SignIn) {
							locksurface.state = Ctrl.LockSurface.Cover;
							inactive.start();
						} else inactive.triggered();
					}
					else {
						inactive.stop();
						Quickshell.execDetached(['niri', 'msg', 'action', 'power-on-monitors']);
					}
				}

				Timer { id: inactive
					interval: monitor.timeout *1000
					onTriggered: Quickshell.execDetached(['niri', 'msg', 'action', 'power-off-monitors']);
				}
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
					width: window.width; height: window.screen.height;
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
					from: -window.screen.height; to: 0;
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
					to: -window.screen.height; from: 0;
					duration: 500; easing.type: Easing.OutCirc;
				}
			}

			Connections {
				target: root

				function onLock(anim) {
					if (anim) lockAnim.start();
					else {
						window.visible = true;
						lock.locked = true;
						sourceItem.state = Ctrl.LockSurface.State.SignIn;
					}
				}
				function onUnlock() { unlockAnim.start(); }
			}
		}
	}

	IpcHandler {
		target: "lockscreen"
		function lock(anim: bool): void { root.lock(anim); }
		function unlock(): void { context.unlocked(); }
	}
}
