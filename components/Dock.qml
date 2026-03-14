import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../globals.js" as Globals

Variants { id: root
	property int height: 48
	property list<Item> widgets: []

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

				 if (x && y) {
					 trans.y = 0
					 if (timer.running) timer.stop();
				} else timer.restart();
			}
		}

		Timer { id: timer
			interval: 250
			onTriggered: trans.y = dock.height;
		}

		Item { id: dock
			x: parent.width /2 -width /2; y: parent.height -height;
			width: layout.width; height: root.height +Globals.Controls.padding;
			transform: Translate { id: trans
				y: dock.height;

				Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.InOutCirc; }}
			}
			opacity: 1.0 -(trans.y /dock.height)

			RectangularShadow {
				width: parent.width; height: root.height;
				radius: Globals.Controls.radius
				blur: 30
				opacity: 0.975 *0.4
			}

			Rectangle {
				width: parent.width; height: root.height;
				radius: Globals.Controls.radius
				color: Globals.Colours.mid
				opacity: 0.975
			}

			Row { id: layout
				spacing: Globals.Controls.spacing *2
				leftPadding: Globals.Controls.spacing
				rightPadding: Globals.Controls.spacing
				height: root.height
				Component.onCompleted: root.widgets.forEach(w => {
					w.parent = layout;
					w.anchors.verticalCenter = layout.verticalCenter;
					w.children.forEach(c => {
						if (c.hasOwnProperty('anchor')) c.anchor = Edges.Bottom;
						if (c.hasOwnProperty('verticalOffset')) c.verticalOffset = -dock.height;
					});
				});
			}
		}
	}
}
