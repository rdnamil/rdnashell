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
	onLoaded: {
		root.item.x = Globals.Controls.spacing /2 -Globals.Controls.padding /2;
		root.item.y = -Globals.Controls.padding /2;
	}

	Ctrl.Button { id: btn
		width: root.width
		height: icon.height
		onClicked: root.open();

		icon: RowLayout { id: boxLayout
			width: btn.width
			spacing: 0

			IconImage { id: selectIcon
				visible: root.model[root.currentIndex]?.icon? true : false
				Layout.margins: Globals.Controls.spacing
				Layout.leftMargin: Globals.Controls.padding /2
				Layout.rightMargin: 0
				implicitSize: selectText.height
				source: visible? Quickshell.iconPath(root.model[root.currentIndex]?.icon, true) : ''
			}

			Text { id: selectText
				Layout.margins: Globals.Controls.spacing
				Layout.leftMargin: selectIcon.visible? 0 : Globals.Controls.padding /2
				Layout.fillWidth: true
				text: root.currentIndex !== -1? root.model[root.currentIndex].text : ""
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
	}
}
