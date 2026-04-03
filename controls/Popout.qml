/*--------------------------
--- Popout.qml by andrel ---
--------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.services as Service
import "../globals.js" as Globals

Item { id: root
	required property Item content

	readonly property ShellScreen screen: root.QsWindow.window?.screen || Quickshell.screens[0]
	readonly property bool isTransitioning: anim.running

	property int anchor
	property int verticalOffset
	property bool centreHorizontally
	property bool stealFocus
	property bool isOpen

	signal open()
	signal close()

	function toggle() { root.isOpen = !root.isOpen; }

	function positionContainer() {
		const x = (root.mapToGlobal(0, 0).x -root.screen.x) +root.parent.width /2;

		if (root.centreHorizontally) container.x = root.screen.width /2 -container.width /2;
		else if (x -root.content.width /2 -Globals.Controls.padding < 0) container.x = Globals.Controls.padding;
		else if (x +root.content.width /2 +Globals.Controls.padding > root.screen.width) container.x = root.screen.width -root.content.width -Globals.Controls.padding;
		else container.x = x -root.content.width /2;

		if (root.anchor === Edges.Top) {
			container.anchors.top = container.parent.top;
			container.anchors.topMargin = Globals.Controls.padding /2 +((root.verticalOffset ?? 0) > 0? Math.abs(root.verticalOffset) : 0);
			trans.startingPos = (root.content.height +Globals.Controls.padding) *(-1);
		} else if (root.anchor === Edges.Bottom) {
			container.anchors.bottom = container.parent.bottom;
			container.anchors.bottomMargin = Globals.Controls.padding /2 +((root.verticalOffset ?? 0) < 0? Math.abs(root.verticalOffset) : 0);
			trans.startingPos = (root.content.height +Globals.Controls.padding);
		}
	}

	anchors.fill: parent
	onIsOpenChanged: {
		anim.restart();

		if (root.isOpen) {
			root.open();
			if (root.parent.countUp) root.parent.countUp();
			Service.PopoutManager.whosOpen = root;
		} else {
			if (root.parent.countDown) root.parent.countDown();
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
		mask: Region {
			y: (root.verticalOffset ?? 0) > 0? root.verticalOffset : 0;
			width: window.width; height: window.height -Math.abs(root.verticalOffset ?? 0);
		}
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		color: Globals.Settings.debug? "#400000ff" : "transparent"

		MouseArea { anchors.fill: parent; onClicked: root.isOpen = false; }

		ParallelAnimation { id: anim
			onStarted: if (root.isOpen) {
				window.visible = true;
				root.positionContainer();
			}
			onFinished: if (!root.isOpen) window.visible = false;

			NumberAnimation {
				target: container; property: "opacity";
				to: root.isOpen? 0.975 : 0.0
				duration: 250; easing.type: root.isOpen? Easing.OutCirc : Easing.InCirc;
			}

			NumberAnimation {
				target: trans; property: "y";
				to: root.isOpen? 0 : trans.startingPos
				duration: 250; easing.type: root.isOpen? Easing.OutCirc : Easing.InCirc;
			}
		}

		Item { id: container
			width: root.content.width; height: root.content.height;
			transform: Translate { id: trans
				property real startingPos;

				y: startingPos
			}
			opacity: 0.0
			focus: !root.stealFocus
			Keys.onPressed: event => { if (event.key == Qt.Key_Escape) root.isOpen = false; }
			Component.onCompleted: root.content.parent = container;

			MouseArea { anchors.fill: parent; }

			RectangularShadow {
				anchors.fill: parent
				radius: Globals.Controls.radius
				blur: 30
				opacity: 0.4 *container.opacity
			}

			Rectangle {
				anchors.fill: parent
				radius: Globals.Controls.radius
				color: Globals.Settings.debug? "#8000ff00" : "transparent"
			}
		}
	}

	Connections {
		target: Service.PopoutManager

		function onWhosOpenChanged() { root.isOpen = (Service.PopoutManager.whosOpen === root); }
	}
}
