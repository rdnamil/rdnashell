/*--------------------------
--- Popout.qml by andrel ---
--------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.services as Service
import "../globals.js" as Globals

Item { id: root
	required property Item content

	readonly property PopupWindow window: window

	property bool isOpen

	signal open()
	signal close()

	function toggle() { root.isOpen = !root.isOpen; }

	anchors.fill: parent
	onIsOpenChanged: {
		if (root.isOpen) {
			root.open();
			Service.PopoutManager.whosOpen = root;
		} else {
			root.close();
			if (Service.PopoutManager.whosOpen === root) Service.PopoutManager.whosOpen = null;
		}
	}

	Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; color: "#8000ff00"; }

	PanelWindow {
		visible: root.isOpen
		screen: window.screen
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		color: Globals.Settings.debug? "#40ff0000" : "transparent"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

		MouseArea {
			anchors.fill: parent
			focus: true
			onClicked: root.isOpen = false;
			Keys.onPressed: event => { if (event.key == Qt.Key_Escape) root.isOpen = false; }
		}
	}

	PopupWindow { id: window
		mask: Region {
			x: contentWrapper.x
			y: contentWrapper.y
			width: contentWrapper.width
			height: contentWrapper.height
		}
		color: Globals.Settings.debug? "#80ff0000" : "transparent"
		implicitWidth: root.content.width +Globals.Controls.padding *2 +shadow.blur *2
		implicitHeight: root.content.height +Globals.Controls.padding *2 +shadow.blur *2
		anchor {
			item: root
			// if the window would go off-screen, slideX until it is back on-screen
			// avoids Quickshell's default 12px padding and will touch the screen's edge
			margins.left: if ((window.itemRect(root).x +root.width /2 +root.content.width /2 +Globals.Controls.padding *2) > window.screen.width) {
				return window.screen.width -window.itemRect(root).x -root.content.width /2 -Globals.Controls.padding;
			} else if ((window.itemRect(root).x +root.width /2 -root.content.width /2 -Globals.Controls.padding *2) < 0) {
				return root.content.width /2 -window.itemRect(root).x +Globals.Controls.padding;
			} else return root.width /2;
			edges: Edges.Bottom | Edges.Left
			gravity: Edges.Bottom
			adjustment: PopupAdjustment.None
		}
		Component.onCompleted: { root.content.parent = contentWrapper; }

		Translate { id: trans; }

		RectangularShadow { id: shadow
			anchors.horizontalCenter: parent.horizontalCenter
			y: contentWrapper.y
			z: -999
			width: contentWrapper.width
			height: contentWrapper.height
			radius: Globals.Controls.radius
			blur: 30
			opacity: 0.4 *contentWrapper.opacity
			transform: trans
		}

		Item { id: contentWrapper
			x: window.width /2 -width /2
			y: (Globals.Settings.barIsTop? 0 : window.width -width) +Globals.Controls.padding *(Globals.Settings.barIsTop? 1 : -1)
			width: root.content.width
			height: root.content.height
			transform: trans
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Rectangle {
				width: contentWrapper.width
				height: contentWrapper.height
				radius: Globals.Controls.radius
			}}
		}

		ParallelAnimation { id: contentAnim
			onStarted: if (root.isOpen) window.visible = true;
			onFinished: if (!root.isOpen) window.visible = false;
			NumberAnimation {
				target: contentWrapper; property: "opacity"; duration: 250; easing.type: Easing.OutCirc;
				from: root.isOpen? 0.0 : 0.975
				to: !root.isOpen? 0.0 : 0.975
			}
			NumberAnimation {
				target: trans; property: "y"; duration: 250;
				easing.type: root.isOpen? Easing.OutCirc : Easing.InCirc
				from: root.isOpen? -(root.content.height +Globals.Controls.padding) : Globals.Controls.padding
				to: !root.isOpen? -(root.content.height +Globals.Controls.padding) : Globals.Controls.padding
			}
		}

		Connections {
			target: root

			function onIsOpenChanged() { contentAnim.start(); }
		}
	}

	Connections {
		target: Service.PopoutManager

		function onWhosOpenChanged() { root.isOpen = (Service.PopoutManager.whosOpen === root); }
	}
}
