pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io

Singleton { id: root
	readonly property NotificationServer server: NotificationServer { id: server
		keepOnReload: false
		actionsSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		bodyMarkupSupported: true
		imageSupported: true

		onNotification: (notif) => {
			notif.tracked = true;

			root.notify(notif);
		}
	}
	readonly property Item connections: Item { Repeater { id: connections
		model: ScriptModel { values: [...root.server.trackedNotifications.values] }
		delegate: Item { id: delegate
			required property var modelData

			Component.onCompleted: {
				// console.log(`Notifications: Connection to id#${delegate.modelData.id} created`)
			}

			Connections {
				target: delegate.modelData

				function onClosed(reason) {
					// console.log(NotificationCloseReason.toString(reason));

					root.expire(delegate.modelData.id);
					root.dismiss(delegate.modelData.id);
				}
			}
		}
	}}

	property bool dnd

	signal notify(Notification notif)
	signal expire(int id)
	signal dismiss(int id)

	function clearall() {
		[...root.server.trackedNotifications.values].forEach(n => n.dismiss());
	}

	IpcHandler {
		target: "notification"
	}
}
