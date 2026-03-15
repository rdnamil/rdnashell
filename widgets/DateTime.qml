/*----------------------------
--- DateTime.qml by andrel ---
----------------------------*/

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Widget { id: root
	readonly property SystemClock clock: SystemClock { id: clock; precision: SystemClock.Seconds; }

	property bool stack

	icon: GridLayout {
		rowSpacing: 0
		columnSpacing: Globals.Controls.spacing
		columns: root.stack? 1 : 3
		width: {
			const w = Math.round(implicitWidth);
			return w +w %2;
		}

		Text {
			Layout.alignment: root.stack? Qt.AlignHCenter : 0
			text: Qt.formatDate(root.clock.date, "ddd d")
			color: Globals.Colours.light
			font.pointSize: 10
			font.weight: 500
		}
		Rectangle {
			visible: !root.stack
			Layout.preferredWidth: 4; Layout.preferredHeight: width; radius: height /2;
			color: Globals.Colours.text
		}
		Text {
			Layout.alignment: root.stack? Qt.AlignHCenter : 0
			text: Qt.formatTime(root.clock.date, "h:mm")
			color: Globals.Colours.text
			font.pointSize: 10
			font.weight: 600
		}
	}
}
