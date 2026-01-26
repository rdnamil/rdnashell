import QtQuick
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Widget { id: root
	width: icon.width +Globals.Controls.padding
	height: icon.height +Globals.Controls.padding
	hoverEnabled: true
	containmentMask: Item {
		width: root.width
		height: root.height
	}

	Rectangle {
		anchors.fill: parent; z: -1; radius: Globals.Controls.radius *( 3/4); color: Globals.Colours.light;
		opacity: parent.containsMouse? 0.25 : 0.0

		Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}
	}
}
