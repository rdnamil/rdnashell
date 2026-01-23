/*--------------------------
--- Widget.qml by andrel ---
--------------------------*/

pragma ComponentBehavior: Bound

import QtQuick

MouseArea { id: root
	required property Item icon

	width: icon.width
	height: parent.height
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
	}
}
