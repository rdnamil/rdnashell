/*--------------------------
 * --- Popout.qml by andrel ---
 * --------------------------*/

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

	readonly property ShellScreen screen: root.QsWindow.window?.screen || Quickshell.screens[0]

	property bool isOpen

	signal open()
	signal close()

	function toggle() { root.isOpen = !root.isOpen; }

	function positionContainer() {
		const p = root.mapToGlobal(0, 0);
		const x = p.x +root.width /2;

		if (x -root.content.width /2 -Globals.Controls.padding < 0) container.x = Globals.Controls.padding;
		else if (x +root.content.width /2 +Globals.Controls.padding > window.screen.width) container.x = window.screen.width -root.content.width -Globals.Controls.padding;
		else container.x = x -root.content.width /2;

		p.y < window.screen.height /2? container.y = p.y +Globals.Controls.padding /2 : p.y -Globals.Controls.padding /2;
	}

	anchors.fill: parent
	onIsOpenChanged: {
		anim.restart();

		if (root.isOpen) {
			root.open();
			root.positionContainer();
			Service.PopoutManager.whosOpen = root;
		} else {
			root.close();
		}
	}

	Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; color: "#8000ff00"; }

	PanelWindow { id: window
		visible: false
		screen: root.screen
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		color: Globals.Settings.debug? "#400000ff" : "transparent"

		MouseArea { anchors.fill: parent; onClicked: root.isOpen = false; }

		Translate { id: trans; y: (container.y +root.content.height) *(-1); }

		ParallelAnimation { id: anim
			onStarted: if (root.isOpen) window.visible = true;
			onFinished: if (!root.isOpen) window.visible = false;

			NumberAnimation {
				target: container; property: "opacity";
				to: root.isOpen? 0.975 : 0.0
				duration: 250; easing.type: root.isOpen? Easing.OutCirc : Easing.InCirc;
			}

			NumberAnimation {
				target: trans; property: "y";
				to: root.isOpen? 0 : (container.y +root.content.height) *(-1)
				duration: 250; easing.type: root.isOpen? Easing.OutCirc : Easing.InCirc;
			}
		}

		RectangularShadow {
			anchors.fill: container
			radius: Globals.Controls.radius
			blur: 30
			opacity: 0.4 *container.opacity
			transform: trans
		}

		Rectangle { id: container
			width: root.content.width; height: root.content.height;
			transform: trans
			color: Globals.Settings.debug? "#8000ff00" : "transparent"
			opacity: 0.0
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Rectangle {
				width: container.width; height: container.height;
				radius: Globals.Controls.radius
			}}
			focus: true
			Keys.onPressed: event => { if (event.key == Qt.Key_Escape) root.isOpen = false; }
			Component.onCompleted: root.content.parent = container;

			Rectangle { visible: Globals.Settings.debug; x: parent.width /2 -width /2; z: 1; width: 1; height: parent.height; color: "black"; }
			Rectangle { visible: Globals.Settings.debug; y: parent.height /2 -height /2; z: 1; width: parent.width; height: 1; color: "black"; }

			MouseArea { anchors.fill: parent; }
		}
	}

	Connections {
		target: Service.PopoutManager

		function onWhosOpenChanged() { root.isOpen = (Service.PopoutManager.whosOpen === root); }
	}
}
