/*-----------------------
--- OSD.qml by andrel ---
-----------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../globals.js" as Globals

Singleton { id: root
	property Item content

	function display(item) {
		root.content = item;
		loader.active = true;
		timer.restart();
	}

	Loader { id: loader
		active: false
		sourceComponent: PanelWindow {
			mask: Region {}
			WlrLayershell.layer: WlrLayer.Overlay
			implicitWidth: background.width +shadow.blur *2
			implicitHeight: background.height +shadow.blur *2
			color: "transparent"

			RectangularShadow { id: shadow
				anchors.fill: background
				radius: background.radius
				blur: 30
				opacity: 0.4 *background.opacity
			}

			Rectangle { id: background
				anchors.centerIn: parent
				width: source.width +Globals.Controls.padding *2
				height: source.height +Globals.Controls.padding *2
				radius: Globals.Controls.radius
				color: Globals.Colours.mid
				opacity: 0.975
			}

			ShaderEffectSource { id: source
				anchors.centerIn: parent
				width: sourceItem.width
				height: sourceItem.height
				sourceItem: root.content
			}
		}
	}

	Timer { id: timer
		interval: 1500
		onTriggered: loader.active = false;
	}
}
