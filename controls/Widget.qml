/*--------------------------
--- Widget.qml by andrel ---
--------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../globals.js" as Globals

MouseArea { id: root
	required property Item icon

	property string tooltip
	property ShaderEffectSource displayedIcon: source

	width: icon.width
	height: parent.height
	hoverEnabled: true
	onExited: if (window.visible) window.visible = false;
	containmentMask: Item {
		y: root.height /2 -height /2
		width: root.icon.width
		height: root.icon.height
	}

	ShaderEffectSource { id: source
		anchors.centerIn: parent;
		sourceItem: root.icon;
		width: root.icon.width
		height: root.icon.height
		mipmap: true
		layer.enabled: true
	}

	Timer { id: ttTimer
		running: root.containsMouse && root.tooltip.trim()
		interval: 1000
		onTriggered: {window.setRect(); window.visible = true;}
	}

	PopupWindow { id: window
		function setRect() {
			const x = root.mouseX; const y = root.mouseY;
			window.anchor.rect.x = x +8;
			window.anchor.rect.y = y +12;
		}

		anchor.item: root
		mask: Region {}
		implicitWidth: text.width
		implicitHeight: text.height
		color: "transparent"

		Rectangle {
			anchors.fill: text;
			radius: 2
			color: Globals.Colours.base
			border { width: 1; color: Globals.Colours.mid; }
			opacity: 0.975
		}

		Text { id: text
			padding: Globals.Controls.spacing
			text: root.tooltip
			font.pointSize: 8
			font.italic: true
			color: Globals.Colours.light
		}
	}
}
