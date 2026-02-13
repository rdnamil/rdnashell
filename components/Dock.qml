/*------------------------
--- Dock.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.controls as Ctrl
import "../globals.js" as Globals

Variants { id: root
	property list<Item> widgets: []

	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		screen: modelData
		anchors.bottom: true
		mask: Region {
			x: window.width /2 -width /2; y: window.height -height
			width: window.width *(2 /3); height: 1;

			Region { x: dock.x; y: trans.y; width: dock.width; height: dock.height; }
		}
		exclusiveZone: 0
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:dock"
		implicitWidth: screen.width
		implicitHeight: dock.height +shadow.blur
		color: Globals.Settings.debug? "#40ff0000" : "transparent"

		Rectangle {
			visible: Globals.Settings.debug
			anchors.fill: parent
			color: "#8000ff00"
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Item {
				width: window.width; height: window.height;

				Rectangle {
					x: window.width /2 -width /2; y: window.height -height
					width: window.width *(2 /3); height: 1;
				}

				Rectangle { x: dock.x; y: trans.y; width: dock.width; height: dock.height; }
			}}
		}

		MouseArea {
			anchors.bottom: parent.bottom
			width: parent.width
			height: 1
			hoverEnabled: true
			onEntered: {
				trans.y = shadow.blur;
				grace.restart();
			}
		}

		Item { id: dock
			x: window.width /2 -width /2
			width: windows.width; height: windows.height +Globals.Controls.padding;
			transform: Translate { id: trans
				y: window.height +Globals.Controls.padding

				Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}
			}
			opacity: 0.975

			RectangularShadow { id: shadow
				anchors.fill: windows
				blur: 30
				radius: Globals.Controls.radius
				opacity: dock.opacity *0.4
			}

			Rectangle {
				anchors.fill: windows
				radius: Globals.Controls.radius
				color: Globals.Colours.mid
			}

			Row { id: windows
				padding: Globals.Controls.padding
				spacing: Globals.Controls.spacing

				Item { width: 10; height: 10; }
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered: grace.stop();
				onExited: grace.start();
			}
		}

		Timer { id: grace
			interval: 1000
			onTriggered: trans.y = window.height +Globals.Controls.padding;
		}
	}
}
