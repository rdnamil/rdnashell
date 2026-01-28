pragma ComponentBehavior: Bound

import QtQuick
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Widget { id: root
	property bool enabled: true

	width: icon.width +Globals.Controls.padding
	height: icon.height +Globals.Controls.padding
	onPressed: pressAnim.restart();
	onReleased: if (!pressAnim.running) bak.opacity = Qt.binding(() => root.containsMouse? 0.25 : 0.0);
	containmentMask: Item {
		width: root.width
		height: root.height
	}

	Rectangle { id: bak
		visible: root.enabled
		anchors.fill: parent; z: -1; radius: Globals.Controls.radius *( 3/4); color: Globals.Colours.light;
		opacity: parent.containsMouse? 0.25 : 0.0

		Behavior on opacity { NumberAnimation { alwaysRunToEnd: true; duration: 250; easing.type: Easing.OutCirc; }}
	}

	NumberAnimation { id: pressAnim
		target: bak; property: "opacity";
		from: bak.opacity; to: 0.1;
		duration: 50; easing.type: Easing.InOutCirc;
		onFinished: root.pressed? bak.opacity = 0.1 : bak.opacity = Qt.binding(() => root.containsMouse? 0.25 : 0.0);
	}
}
