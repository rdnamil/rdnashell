/*------------------------------------
--- NotificationTray.qml by andrel ---
------------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Ctrl.Widget { id: root
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: Service.Notifications.dnd? Quickshell.iconPath("notifications-disabled") : Quickshell.iconPath("notification", "notification-inactive")
	}
	onClicked: popout.toggle()

	Ctrl.Popout { id: popout
		content: Rectangle { width: 400; height: 100; }
	}
}
