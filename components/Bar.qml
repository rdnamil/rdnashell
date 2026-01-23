/*-----------------------
--- Bar.qml by andrel ---
-----------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../globals.js" as Globals

Variants { id: root
	property int height: 38
	property list<Item> left: []
	property list<Item> centre: []
	property list<Item> right: []

	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		screen: modelData
		anchors {
			left: true
			right: true
			top: Globals.Settings.barIsTop
			bottom: !Globals.Settings.barIsTop
		}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:bar"
		implicitHeight: root.height
		color: Globals.Settings.debug? "#80ff0000" : "transparent"

		Rectangle {
			visible: !Globals.Settings.debug
			anchors.fill: parent
			color: "black"
			layer.enabled: true
			layer.effect: OpacityMask {
				invert: true
				maskSource: bar
			}
		}

		Rectangle { id: bar
			visible: !Globals.Settings.debug
			anchors.fill: parent
			topRightRadius:  window.anchors.top? height /4 : 0
			topLeftRadius: window.anchors.top? height /4 : 0
			bottomRightRadius:  window.anchors.top? 0 : height /4
			bottomLeftRadius: window.anchors.top? 0 : height /4
			color: Globals.Colours.dark
			opacity: 0.975

			Rectangle {
				anchors {
					top: window.anchors.top? undefined : parent.top
					bottom: window.anchors.top? parent.bottom : undefined
				}
				width: parent.width
				height: 1
				color: Globals.Colours.mid
			}
		}

		// left items
		Row { id: rowLeft
			anchors.verticalCenter: parent.verticalCenter
			leftPadding: Globals.Controls.padding
			spacing: Globals.Controls.spacing
			height: parent.height

			Component.onCompleted: { for (let w of root.left) {
				w.parent = rowLeft;
				w.anchors.verticalCenter = rowLeft.verticalCenter;
			}}
		}

		// center items
		Row { id: rowCentre
			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
			spacing: Globals.Controls.spacing
			height: parent.height

			Component.onCompleted: { for (let w of root.centre) {
				w.parent = rowCentre;
				w.anchors.verticalCenter = rowCentre.verticalCenter;
			}}
		}

		// right items
		Row { id: rowRight
			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			rightPadding: Globals.Controls.padding
			spacing: Globals.Controls.spacing
			height: parent.height

			Component.onCompleted: { for (let w of root.right) {
				w.parent = rowRight;
				w.anchors.verticalCenter = rowRight.verticalCenter;
			}}
		}
	}
}
