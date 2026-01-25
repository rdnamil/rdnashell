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
			if (!root.dnd) root.toast.values.splice(0, 0, notif);
			if (!root.dnd) root.history.values.splice(0, 0, notif);
		}
	}
	readonly property ScriptModel toast: ScriptModel { id: toast; objectProp: "id"; }
	readonly property ScriptModel history: ScriptModel { id: history; objectProp: "id"; }

	property bool dnd

	signal dismiss(int id)

	onDismiss: (id) => {
		root.history.values.splice(root.history.values.findIndex(n => n.id === id), 1);
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

	IpcHandler {
		target: "notification"

		function clearall(): void { server.trackedNotifications.values.forEach(n => root.dismiss(n.id)); }
	}
}
