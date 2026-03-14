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
	readonly property Item spread: RowLayout {
		spacing: Globals.Controls.spacing
		width: {
			const w = Math.round(implicitWidth);
			return w +w %2;
		}

		Text {
			text: Qt.formatDate(root.clock.date, "ddd d")
			color: Globals.Colours.light
			font.pointSize: 10
			font.weight: 500
		}
		Rectangle {
			Layout.alignment: Qt.AlignVCenter
			Layout.preferredWidth: 4; Layout.preferredHeight: width; radius: height /2;
			color: Globals.Colours.text
		}
		Text {
			text: Qt.formatTime(root.clock.date, "h:mm")
			color: Globals.Colours.text
			font.pointSize: 10
			font.weight: 600
		}
	}
	readonly property Item stacked: ColumnLayout {
		spacing: 0
		width: {
			const w = Math.round(implicitWidth);
			return w +w %2;
		}

		Text {
			Layout.alignment: Qt.AlignHCenter
			text: Qt.formatDate(root.clock.date, "ddd d")
			color: Globals.Colours.light
			font.pointSize: 10
			font.weight: 500
		}
		Text {
			Layout.alignment: Qt.AlignHCenter
			text: Qt.formatTime(root.clock.date, "h:mm")
			color: Globals.Colours.text
			font.pointSize: 10
			font.weight: 600
		}
	}

	property bool stack

	icon: root.stack? stacked : spread
}
