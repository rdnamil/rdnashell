/*-------------------------------
--- LockSurface.qml by andrel ---
-------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Io
import qs.controls as Ctrl
import "../globals.js" as Globals

Item { id: root
	required property Ctrl.LockContext context
	required property url wallpaper

	anchors.fill: parent

	Rectangle { anchors.fill: parent; color: Globals.Colours.mid; }

	Image {
		anchors.fill: parent
		source: root.wallpaper
	}

	Rectangle {
		anchors.centerIn: parent
		width: childrenRect.width
		height: childrenRect.height

		Text {
			text: "unlock me"
			MouseArea {
				anchors.fill: parent
				onClicked: root.context.unlocked();
			}
		}
	}
}
