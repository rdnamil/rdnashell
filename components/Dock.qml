import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../globals.js" as Globals

Variants { id: root
	property int height: 48

	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		screen: modelData
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		mask: Region { id: mask
			x: window.width /2 -width /2; y: window.height -height
			width: dock.width +64; height: 1;

			Region {
				width: dock.width +64; height: window.height -dock.y +32;
				x: dock.x -32; y: dock.y -32;
				intersection: trans.y < dock.height? Intersection.Combine : Intersection.Intersect
			}
		}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:dock"
		color: Globals.Settings.debug? "#40ff0000" : "transparent"

		Item { // mask
			anchors.fill: parent

			Rectangle {
				x: window.width /2 -width /2; y: window.height -height
				width: dock.width +72; height: 1;
				color: Globals.Settings.debug? "#ffff0000" : "transparent"
			}

			Rectangle {
				visible: trans.y < dock.height
				width: dock.width +64; height: window.height -dock.y +32;
				x: dock.x -32; y: dock.y -32;
				color: Globals.Settings.debug? "#40ff0000" : "transparent"
			}
		}

		MouseArea { id: mousearea
			anchors.fill: parent
			hoverEnabled: true
			onPositionChanged: (mouse) => {
				const x = mouse.x > dock.x && mouse.x < dock.x +dock.width;
				const y = mouse.y > dock.y

				x && y? trans.y = 0 : timer.restart();
			}
		}

		Translate { id: trans
			y: dock.height;

			Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.InOutCirc; }}
		}

		Timer { id: timer
			interval: 250
			onTriggered: trans.y = dock.height;
		}

		Item { id: dock
			x: parent.width /2 -width /2; y: parent.height -height;
			width: 100; height: root.height +Globals.Controls.padding;

			RectangularShadow {
				width: parent.width; height: root.height;
				radius: Globals.Controls.radius
				blur: 30
				opacity: 0.975 *0.4
				transform: trans
			}

			Rectangle {
				width: parent.width; height: root.height;
				radius: Globals.Controls.radius
				color: Globals.Colours.mid
				opacity: 0.975
				transform: trans
			}
		}
	}
}
