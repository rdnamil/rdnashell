/*--------------------------
--- Redeye.qml by andrel ---
--------------------------*/

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Ctrl.Widget { id: root
	onClicked: {
		Service.Sunsetr.toggle();
		Service.PopoutManager.whosOpen = null; // close any open popouts
	}

	icon: IconImage { id: widget
		implicitSize: Globals.Controls.iconSize
		source: Service.Sunsetr.enabled? Quickshell.iconPath("night-light-symbolic") : Quickshell.iconPath("night-light-disabled-symbolic")
	}
}
