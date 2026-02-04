/*----------------------------
--- Settings.qml by andrel ---
----------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.controls as Ctrl
import "../globals.js" as Globals

Singleton { id: root
	function init() {}

	FloatingWindow { id: window
		visible: true

		Rectangle {
			anchors.fill: parent
			color: Globals.Colours.mid
		}

		ColumnLayout {
			anchors.fill: parent

			Rectangle {
				Layout.alignment: Qt.AlignTop
				Layout.fillWidth: true
				Layout.preferredHeight: childrenRect.height
				color: Globals.Colours.dark

				Text {
					anchors.centerIn: parent
					padding: Globals.Controls.spacing
					text: "Settings"
					color: Globals.Colours.text
					font.pointSize: 12
					font.weight: 500
				}
			}

			RowLayout {
				Ctrl.List {
					model: []
					delegate: Item {}
				}
			}
		}
	}
}
