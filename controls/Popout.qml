/*--------------------------
--- Popout.qml by andrel ---
--------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import "../globals.js" as Globals

Item { id: root
	required property Item content

	property bool isOpen

	function toggle() { root.isOpen = !root.isOpen; }

	anchors.fill: parent

	Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; color: "#8000ff00"; }

	PopupWindow { id: window
		mask: Region {
			x: contentWrapper.x
			y: contentWrapper.y
			width: contentWrapper.width
			height: contentWrapper.height
		}
		color: Globals.Settings.debug? "#80ff0000" : "transparent"
		implicitWidth: root.content.width +Globals.Controls.padding *2 +30
		implicitHeight: root.content.height +Globals.Controls.padding *2 +30
		anchor {
			item: root
			// if the window would go off-screen, slideX until it is back on-screen
			// avoids Quickshell's default 12px padding and will touch the screen's edge
			margins.left: if ((window.itemRect(root).x +root.content.width /2 +Globals.Controls.padding *2) > window.screen.width) {
				return window.screen.width -window.itemRect(root).x -root.content.width /2 -Globals.Controls.padding;
			} else if ((window.itemRect(root).x -root.content.width /2 -Globals.Controls.padding *2) < 0) {
				return root.content.width /2 +Globals.Controls.padding -window.itemRect(root).x;
			} else return root.width /2;
			edges: (Globals.Settings.barIsTop? Edges.Bottom : Edges.Top) | Edges.Left
			gravity: Globals.Settings.barIsTop? Edges.Bottom : Edges.Top
			adjustment: PopupAdjustment.None
		}

		RectangularShadow {
			anchors.horizontalCenter: parent.horizontalCenter
			y: contentWrapper.y +contentTrans.y
			z: -999
			width: contentWrapper.width
			height: contentWrapper.height
			radius: Globals.Controls.radius
			blur: 30
			opacity: 0.4 *contentWrapper.opacity
		}

		Item { id: contentWrapper
			x: window.width /2 -width /2
			y: (Globals.Settings.barIsTop? 0 : window.width -width) +Globals.Controls.padding *(Globals.Settings.barIsTop? 1 : -1)
			width: root.content.width
			height: root.content.height
			transform: Translate { id: contentTrans; }
			layer.enabled: true
			layer.effect: OpacityMask {
				maskSource: Rectangle {
					width: contentWrapper.width
					height: contentWrapper.height
					radius: Globals.Controls.radius
				}
			}
		}

		ParallelAnimation { id: contentAnim
			property bool dir

			onStarted: if (root.isOpen) window.visible = true;
			NumberAnimation {
				target: contentWrapper; property: "opacity"; duration: 250; easing.type: Easing.OutCirc;
				from: root.isOpen? 0.0 : 0.975
				to: root.isOpen? 0.975 : 0.0
			}
			NumberAnimation {
				target: contentTrans; property: "y"; duration: 250; easing.type: Easing.OutCirc;
				from: root.isOpen? (window.height +Globals.Controls.padding) *(Globals.Settings.barIsTop? -1 : 1) : 0
				to: root.isOpen? 0 : (window.height +Globals.Controls.padding) *(Globals.Settings.barIsTop? -1 : 1)
			}
			onFinished: if (!root.isOpen) window.visible = false;
		}

		Connections {
			target: root

			function onIsOpenChanged() { contentAnim.restart(); }
		}

		Component.onCompleted: { root.content.parent = contentWrapper; }
	}
}
