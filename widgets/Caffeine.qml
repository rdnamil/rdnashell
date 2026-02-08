/*----------------------------
--- Caffeine.qml by andrel ---
----------------------------*/

import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Widget { id: root
	onClicked: inhibitor.enabled = !inhibitor.enabled;
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: inhibitor.enabled? Quickshell.iconPath("caffeine-cup-full") : Quickshell.iconPath("caffeine-cup-empty")
	}

	IdleInhibitor { id: inhibitor
		window: root
	}
}
