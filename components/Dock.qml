/*------------------------
--- Dock.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.services as Service
import "../globals.js" as Globals

Variants { id: root
	// readonly property Timer timer: grace

	property list<Item> widgets: []

	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		screen: modelData
		anchors.bottom: true
		exclusiveZone: 0
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:dock"
		implicitWidth: screen.width *(2 /3)
		implicitHeight: 1
		color: Globals.Settings.debug? "#40ff0000" : "transparent"

		MouseArea {
			anchors.bottom: parent.bottom
			width: parent.width
			height: 1
			hoverEnabled: true
			onEntered: {
				dockTrans.y = 0;
				if (!grace.locked) grace.restart();
			}
		}

		Timer { id: grace
			property bool locked

			interval: 1000
			onTriggered: dockTrans.y = dock.height +Globals.Controls.padding;
		}

		PopupWindow { id: dockWindow
			readonly property Translate dockTrans: Translate { id: dockTrans
				y: dock.height +Globals.Controls.padding

				Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}
			}

			visible: true
			anchor {
				window: window
				rect { x: window.width /2 -width /2; y: window.height -height; }
				adjustment: PopupAdjustment.None
			}
			mask: Region {
				x: dockWindow.width /2 -width /2
				y: shadow.blur +(dockTrans.y)
				width: dock.width
				height: dock.height +Globals.Controls.padding
			}
			// implicitWidth: dock.width +shadow.blur *2
			implicitWidth: window.screen.width
			implicitHeight: dock.height +Globals.Controls.padding +shadow.blur
			color: Globals.Settings.debug? "#4000ff00" : "transparent"

			RectangularShadow { id: shadow
				anchors.fill: dock
				radius: Globals.Controls.radius
				blur: 30
				opacity: dock.opacity *0.4
				transform: dockTrans
			}

			Rectangle {
				anchors.fill: dock
				radius: Globals.Controls.radius
				color: Globals.Colours.base
				transform: dockTrans
			}

			Row { id: dock
				padding: Globals.Controls.padding
				spacing: Globals.Controls.spacing
				x: dockWindow.width /2 -width /2
				y: shadow.blur
				height: 48
				opacity: dock.y /dockTrans.y
				transform: dockTrans

				Component.onCompleted: { for (let w of root.widgets) {
					w.parent = dock;
					w.anchors.verticalCenter = dock.verticalCenter;
				}}
			}

			MouseArea { id: mousearea
				anchors.fill: parent
				hoverEnabled: true
				propagateComposedEvents: true
				acceptedButtons: Qt.NoButton
				onEntered: grace.stop();
				onExited: if (!grace.locked) grace.restart();
			}
		}

		Connections {
			target: Service.PopoutManager

			function onWhosOpenChanged() {
				if (root.widgets.some(w => w.children.includes(Service.PopoutManager.whosOpen))) {
					if (!grace.locked) {
						console.log("Dock: Lock grace timer");
						grace.locked = true;
					}
				}
				else if (grace.locked) {
					console.log("Dock: Unlock grace timer");
					grace.locked = false;

					if (!mousearea.containsMouse) grace.restart();
				}
			}
		}
	}
}
