/*---------------------------
--- Battery.qml by andrel ---
---------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import "../globals.js" as Globals

Item { id: root
	readonly property color healthColour: {
		if (percentage > (1 /3)) return "green";
		else if (percentage > (1 /6)) return "orange";
		else return "red";
	}
	readonly property bool isLow: percentage <= (1 /6)

	property real percentage: 1.0
	property bool isCharging

	width: 12
	height: Globals.Controls.iconSize +1

	Rectangle {
		anchors.horizontalCenter: parent.horizontalCenter
		height: 1; width: 4;
		color: Globals.Colours.text
	}

	Rectangle {
		anchors.bottom: parent.bottom
		width: parent.width; height: parent.height -1;
		radius: 4
		color: "transparent"
		border { width: 1; color: Globals.Colours.text; }

		Rectangle { id: fill
			anchors.centerIn: parent
			width: parent.width -4; height: parent.height -4;
			color: "transparent"
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Rectangle {
				width: fill.width; height: fill.height;
				radius: 2
			}}

			Rectangle {
				anchors.fill: parent
				color: root.healthColour
				opacity: 0.4
			}

			Rectangle {
				anchors.fill: parent
				transform: Scale { origin.y: fill.height; yScale: root.percentage; }
				color: root.healthColour
			}

			Text {
				visible: text !== ""
				anchors.centerIn: parent
				text: {
					if (root.isLow) return "󱈸";
					else if (root.isCharging) return "󱐋";
					else return "";
				}
				style: Text.Outline
				styleColor: root.healthColour
				color: root.isLow > (1 /6)? Globals.Colours.text : Globals.Colours.dark
				renderType: Text.CurveRendering
				font.pixelSize: parent.height -3
			}
		}
	}
}
