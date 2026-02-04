/*--------------------------------
--- ColourPicker.qml by andrel ---
--------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Ctrl.Widget { id: root
	property color colour: Globals.Colours.accent

	displayedIcon.layer.effect: Colorize { id: colorize
		hue: root.colour.hslHue
		saturation: root.colour.hslSaturation
		lightness: root.colour.hslLightness
	}
	acceptedButtons: Qt.LeftButton | Qt.RightButton
	onClicked: (event) => { switch (event.button) {
		case Qt.LeftButton:
			Service.Niri.pickColour();
			break;
		case Qt.RightButton:
			Quickshell.execDetached(['wl-copy', root.colour]);
			break;
	}}
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: Quickshell.iconPath("color-picker-black")
	}

	Connections {
		target: Service.Niri

		function onColourPicked(colour) {
			root.colour = colour;
			Quickshell.execDetached(['wl-copy', root.colour]);
		}
	}
}
