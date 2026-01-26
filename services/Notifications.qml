/*---------------------------------
--- Notifications.qml by andrel ---
---------------------------------*/

pragma Singleton

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
			root.history.values.splice(0, 0, {
				"notif": notif,
				"timestamp": new Date()
			});
			// root.history.values.find(n => n === notif).push({"date": Date.now()});
			if (!root.dnd) root.toast.values.splice(0, 0, notif);
		}
	}
	readonly property ScriptModel toast: ScriptModel { id: toast; objectProp: "id"; }
	readonly property ScriptModel history: ScriptModel { id: history; objectProp: "id"; }

	property bool dnd

	signal dismiss(int id)

	onDismiss: (id) => {
		root.history.values.splice(root.history.values.findIndex(n => n.notif.id === id), 1);
		if (!root.toast.values.find(n => n.id === id)) server.trackedNotifications.values.find(n => n.id === id).dismiss();
	}

	function toastDestroy(id, dismissed = false) {
		root.toast.values.splice(root.toast.values.findIndex(n => n.id === id), 1);
		if (dismissed) server.trackedNotifications.values.find(n => n.id === id).dismiss();
	}

	function toastResend(id) {
		const notif = root.toast.values.splice(root.toast.values.findIndex(n => n.id === id), 1)[0];
		root.toast.values.splice(0, 0, notif);
	}

	function clearall() { server.trackedNotifications.values.forEach(n => root.dismiss(n.id)); }

	IpcHandler {
		target: "notification"
	}
}
