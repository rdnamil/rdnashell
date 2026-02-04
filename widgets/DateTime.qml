/*----------------------------
--- DateTime.qml by andrel ---
----------------------------*/

import QtQuick
import Quickshell
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Widget { id: root
	readonly property SystemClock clock: SystemClock { id: clock; precision: SystemClock.Seconds; }

	icon: Row {
		spacing: Globals.Controls.spacing

		Text {
			text: Qt.formatDate(root.clock.date, "ddd d")
			color: Globals.Colours.light
			font.pointSize: 10
			font.weight: 500
		}
		Rectangle {
			anchors.verticalCenter: parent.verticalCenter
			width: 4; height: width; radius: height /2;
			color: Globals.Colours.text
		}
		Text {
			text: Qt.formatTime(root.clock.date, "h:mm")
			color: Globals.Colours.text
			font.pointSize: 10
			font.weight: 600
		}
	}
}
