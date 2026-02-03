/*----------------------------
--- Dropdown.qml by andrel ---
----------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Button { id: root
	property list<var> model: []
	property int currentIndex: model.length > 0? 0 : -1

	signal selected(int index)

	width: 320
	height: icon.height
	onClicked: loader.item.visible = true;
	icon: RowLayout { id: boxLayout
		width: root.width

		Text {
			Layout.margins: Globals.Controls.spacing
			Layout.leftMargin: Globals.Controls.padding /2
			Layout.fillWidth: true
			text: root.currentIndex !== -1? root.model[root.currentIndex] : ""
			color: Globals.Colours.text
			font.pointSize: 10
		}

		IconImage {
			Layout.margins: Globals.Controls.spacing
			implicitSize: Globals.Controls.iconSize
			source: Quickshell.iconPath("arrow-down")
		}
	}
	background.z: 1

	Loader { id: loader
		active: parent.visible
		sourceComponent: Popup { id: popup
			enabled: true
			margins: 0
			x: -Globals.Controls.spacing
			y: -Globals.Controls.spacing *1.5
			width: root.width +Globals.Controls.spacing *2
			height: list.height
			popupType: Popup.Window
			background: Rectangle {
				width: popup.width
				height: popup.height
				radius: Globals.Controls.radius
				color: Globals.Colours.base
			}

			Ctrl.List { id: list
				anchors.centerIn: parent
				width: popup.width
				onItemClicked: {
					root.currentIndex = list.view.currentIndex;
					popup.visible = false;
				}
				model: root.model
				delegate: Text {
					required property var modelData

					padding: Globals.Controls.spacing
					width: list.availableWidth
					text: modelData
					color: Globals.Colours.text
					font.pointSize: 10
				}
			}
		}
	}
}
