/*------------------------
--- Tray.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Row { id: root
	spacing: Globals.Controls.spacing

	Repeater {
		model: SystemTray.items.values
		delegate: Ctrl.Widget { id: delegate
			required property var modelData

			onClicked: delegate.modelData.activate()
			height: root.parent.height
			icon: IconImage {
				implicitSize: Globals.Controls.iconSize
				source: Quickshell.iconPath(delegate.modelData.id.toLowerCase(), true) || delegate.modelData.icon
			}
		}
	}
}
