/*---------------------------------
--- Notifications.qml by andrel ---
---------------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

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

			let sharedId = false;

			sharedId = root.history.values.some(n => n.notif.id === notif.id);
			if (sharedId) root.history.values.splice(root.history.values.findIndex(n => n.notif.id === notif.id), 1);

			root.history.values.splice(0, 0, {
				"notif": notif,
				"timestamp": new Date(),
				"read": false
			});

			if (!root.dnd) {
				sharedId = root.toast.values.some(n => n.id === notif.id);
				if (sharedId) root.toast.values.splice(root.toast.values.findIndex(n => n.id === notif.id), 1);

				root.toast.values.splice(0, 0, notif);
			}
		}
	}
	readonly property Item connections: Item { Repeater { id: connections
		model: ScriptModel { values: [...root.server.trackedNotifications.values] }
		delegate: Item { id: delegate
			required property var modelData

			Component.onCompleted: console.log(`Notifications: Connection to id#${delegate.modelData.id} created`)

			Connections {
				target: delegate.modelData

				function onClosed(reason) {
					console.log(NotificationCloseReason.toString(reason));
				}
			}
		}
	}}
	readonly property ScriptModel toast: ScriptModel { id: toast; objectProp: "id"; }
	readonly property ScriptModel history: ScriptModel { id: history; objectProp: "id"; }

	property bool dnd

	signal dismiss(int id)

	IpcHandler {
		target: "notification"
	}
}
