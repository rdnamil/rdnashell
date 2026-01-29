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
	// notification server
	readonly property NotificationServer server: NotificationServer { id: server
		keepOnReload: false
		actionsSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		bodyMarkupSupported: true
		imageSupported: true

		onNotification: (notif) => {
			notif.tracked = true;

			// remove notifications with duplicate id's
			while (root.history.values.some(n => n.notif.id === notif.id)) {
				root.history.values.splice(root.history.values.findIndex(n => n.notif.id === notif.id), 1);
			}

			// splice new notification to top of list
			root.history.values.splice(0, 0, {
				"notif": notif,
				"timestamp": new Date(),
				"read": false
			});

			// remove notifications with duplicate id's
			while (root.toast.values.some(n => n.id === notif.id)) {
				root.toast.values.splice(root.toast.values.findIndex(n => n.id === notif.id), 1);
			}

			// splice new notification to top of list
			root.toast.values.splice(0, 0, {
				"notif": notif
			});
		}
	}
	// connection to individual notifications
	readonly property Item connections: Item { Repeater { id: connections
		model: ScriptModel { values: [...root.server.trackedNotifications.values] }
		delegate: Item { id: delegate
			required property var modelData

			// Component.onCompleted: console.log(`Notifications: Connection to id#${delegate.modelData.id} created`)

			Connections {
				target: delegate.modelData

				function onClosed(reason) {
					// console.log(NotificationCloseReason.toString(reason));

					const id = delegate.modelData.id;
					if (root.history.values.some(n => n.notif.id === id)) root.dismiss(id);
				}
			}
		}
	}}
	// notification models
	// 	toast => for popups
	// 	history => for tracking
	readonly property ScriptModel toast: ScriptModel { id: toast; objectProp: "id"; }
	readonly property ScriptModel history: ScriptModel { id: history; objectProp: "id"; }

	property bool dnd

	signal notify(var notif)
	signal expire(int id)
	signal dismiss(int id)

	function clearall() { [...root.history.values].reverse().forEach(n => root.dismiss(n.notif.id)); }

	function clearallToasts() { [...root.toast.values].reverse().forEach(n => root.expire(n.notif.id)); }

	onExpire: (id) => {
		const i = root.toast.values.findIndex(n => n.notif.id === id);
		root.toast.values.splice(i, 1);
	}
	onDismiss: (id) => {
		root.toast.values.splice(root.toast.values.findIndex(n => n.notif.id === id), 1);
		root.history.values.splice(root.history.values.findIndex(n => n.notif.id === id), 1);

		if (root.server.trackedNotifications.values.some(n => n.id === id)) {
			root.server.trackedNotifications.values.find(n => n.id === id).dismiss();
		}
	}

	IpcHandler {
		target: "notification"
	}
}
