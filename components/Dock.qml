pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.services as Service
import "../globals.js" as Globals

Scope { id: root
	property ShellScreen modelData
	property string display

	property int height: 48
	property list<Item> widgets: []

	PanelWindow { id: window
		screen: {
			if (root.modelData) return root.modelData;
			else if (root.display) return Quickshell.screens.find(s => s.name === root.display);
		}
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		mask: Region { id: mask
			x: window.width /2 -width /2; y: window.height -height
			width: window.width /3; height: 1;

			Region {
				x: window.width /2 -width /2; y: window.height -height
				width: window.width /3; height: 1;
				intersection: (ToplevelManager.activeToplevel?.fullscreen || false)? Intersection.Subtract : Intersection.Intersect
			}

			Region {
				x: dock.x; y: dock.y +trans.y;
				width: dock.width; height: dock.height;
			}
		}
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "qs:dock"
		color: Globals.Settings.debug? "#40ff0000" : "transparent"

		Item { // mask
			anchors.fill: parent

			Rectangle {
				x: window.width /2 -width /2; y: window.height -height
				width: window.width /3; height: 1;
				color: Globals.Settings.debug? "#ffff0000" : "transparent"
			}

			Rectangle {
				x: dock.x; y: dock.y +trans.y;
				width: dock.width; height: dock.height;
				color: Globals.Settings.debug? "#40ff0000" : "transparent"
			}
		}

		MouseArea { id: mousearea
			anchors.fill: parent
			hoverEnabled: true
			onEntered: layout.counter++;
			onExited: layout.counter--;
			onClicked: Service.PopoutManager.whosOpen = null;
		}

		Timer { id: timer
			interval: 250
			onTriggered: trans.y = dock.height;
		}

		Item { id: dock
			x: parent.width /2 -width /2; y: parent.height -height;
			width: layout.width; height: root.height +Globals.Controls.padding;
			transform: Translate { id: trans
				y: dock.height

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
				color: Globals.Settings.debug? "#80ff0000" : Globals.Colours.mid
				opacity: 0.975
			}

			Text {
				visible: Globals.Settings.debug
				text: layout.counter
			}

			Row { id: layout
				property int counter

				spacing: Globals.Controls.spacing *2
				height: root.height
				onCounterChanged: if (counter > 0) {
						timer.stop();
						trans.y = 0;
					} else timer.restart();
				Component.onCompleted: { for (const w of root.widgets) {
					w.parent = layout;
					w.anchors.verticalCenter = layout.verticalCenter;
					w.children.forEach(c => {
						if (c.hasOwnProperty('anchor')) c.anchor = Edges.Bottom;
						if (c.hasOwnProperty('verticalOffset')) c.verticalOffset = -dock.height;
					});
				}}
			}
		}
	}
}
