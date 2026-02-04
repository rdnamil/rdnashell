/*--------------------------
--- Switch.qml by andrel ---
--------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Widget { id: root
	property bool toggle

	width: 40
	height: 20
	icon: Rectangle { id: icon
		width: root.width; height: root.height; radius: height /2
		color: root.toggle? "limegreen" : Globals.Colours.mid
		clip: false

		Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCirc; }}

		Rectangle { id: btn
			readonly property int diff: (parent.height -height) /2

			x: diff
			y: parent.height /2 -height /2;
			width: parent.height -4; height: width; radius: height /2
			color: Globals.Colours.text
			transform: Translate {
				id: btnTrans; x: root.toggle? icon.width -btn.width -btn.diff *2 : 0;

				Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.InOutCirc; }}
			}
		}
	}
	containmentMask: Item {
		width: root.width
		height: root.height
	}

	Item { id: shadowWrapper
		// visible: false
		x: btn.x -shadow.blur; y: btn.y -shadow.blur;
		width: btn.width +shadow.blur *2; height: btn.height +shadow.blur *2;
		transform: Translate { x: btnTrans.x; }
		layer.enabled: true
		layer.effect: OpacityMask {
			invert: true
			maskSource: Item {
				width: shadowWrapper.width; height: shadowWrapper.height;

				Rectangle {
					anchors.centerIn: parent
					width: btn.width; height: btn.height; radius: btn.radius;
				}
			}
		}

		RectangularShadow { id: shadow
			anchors.centerIn: parent
			width: btn.width; height: btn.height; radius: btn.radius;
			x: btn.x; y: btn.y;
			offset.y: 2; opacity: 0.8;
		}
	}
}
