/*----------------------------
 * --- Dropdown.qml by andrel ---
 * ----------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.PopupMenu { id: root
	readonly property Ctrl.Button button: btn

	width: 320
	height: btn.height

	Ctrl.Button { id: btn
		width: root.width
		height: icon.height
		onClicked: root.open();

		icon: RowLayout { id: boxLayout
			width: btn.width

			Text {
				Layout.margins: Globals.Controls.spacing
				Layout.leftMargin: Globals.Controls.padding /2
				Layout.fillWidth: true
				text: root.currentIndex !== -1? root.model[root.currentIndex] : ""
				elide: Text.ElideRight
				color: Globals.Colours.text
				font.pointSize: 10
			}

			IconImage {
				Layout.margins: Globals.Controls.spacing
				implicitSize: Globals.Controls.iconSize
				source: Quickshell.iconPath("arrow-down")
			}
		}
		tooltip: parent.tooltip
	}
}
