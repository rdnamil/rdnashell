/*-------------------------------------
--- Weather.qml - widgets by andrel ---
-------------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Ctrl.Widget { id: root
	tooltip: Service.Weather.location
	icon: Item {
		width: childrenRect.width -temp.anchors.rightMargin
		height: childrenRect.height -temp.anchors.bottomMargin

		IconImage { id: iconImage
			implicitSize: Globals.Controls.iconSize
			source: Service.Weather.getIcon();
			opacity: 0.6
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Item {
				width: iconImage.width; height: iconImage.height;

				Text {
					visible: temp.visible
					x: temp.x; y: temp.y;
					text: temp.text
					style: Text.Outline
					font.pointSize: 8
					font.weight: 800
				}
			} invert: true; }
		}

		Item {
			anchors.fill: iconImage

			Text { id: temp
				visible: Service.Weather.forecast
				anchors {
					right: parent.right
					rightMargin: -Globals.Controls.padding *1.5
					bottom: parent.bottom
					bottomMargin: -Globals.Controls.spacing
				}
				text: `${parseInt(Service.Weather.forecast?.current.temperature_2m)}${Service.Weather.forecast?.current_units.temperature_2m}`
				color: Globals.Colours.text
				font.pointSize: 8
			}
		}
	}
}
