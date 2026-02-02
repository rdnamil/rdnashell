/*--------------------------
--- Slider.qml by andrel ---
--------------------------*/

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import "../globals.js" as Globals

Slider { id: root
	leftPadding: 0
	rightPadding: 0
	wheelEnabled: true
	from: 0.0
	to: 1.0
	stepSize: 0.05
	background: Rectangle {
		x: root.leftPadding
		y: root.topPadding + root.availableHeight /2 -height /2
		width: root.availableWidth
		height: 10
		radius: height /2
		color: Globals.Colours.base

		Rectangle {
			anchors.fill: parent
			radius: height /2
			gradient: Gradient {
				orientation: Gradient.Vertical
				GradientStop { position: 0.0; color: "#80000000" }
				GradientStop { position: 1.0; color: "#40000000" }
			}
			border { color: Globals.Colours.light; width: 1; }
		}

		Rectangle {
			anchors {
				left: parent.left
				leftMargin: 2
				verticalCenter: parent.verticalCenter
			}
			width: {
				if (root.visualPosition === 0) return 0;
				else return Math.max((parent.width -4) *root.visualPosition, height)
			}
			height: parent.height -4
			radius: height /2
			color: Globals.Colours.accent
		}
	}
	handle: Rectangle { id: handle
		anchors.verticalCenter: parent.verticalCenter
		width: 12
		height: width
		transform: Translate { x: root.visualPosition *(root.availableWidth -handle.width)}
		color: "transparent"
	}

	Rectangle {
		visible: false
		width: text.width
		height: text.height
		radius: 2
		color: Globals.Colours.base
		border { width: 1; color: Globals.Colours.mid; }
		opacity: 0.975

		Text { id: text
			padding: Globals.Controls.spacing
			text: "test"
			font.pointSize: 8
			font.italic: true
			color: Globals.Colours.light
		}
	}
}
