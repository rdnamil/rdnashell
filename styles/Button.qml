import QtQuick
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Widget { id: root
	width: icon.width
	height: icon.height

	property bool toggled

	// Rectangle {
	// 	anchors.fill: parent
	// 	radius: Globals.Controls.radius *(3 /4)
	// 	color: "transparent"
	// 	border { width: 1; color: Globals.Colours.dark; }
 //
	// 	Rectangle {
	// 		anchors.centerIn: parent
	// 		width: parent.width -2; height: parent.height -2; radius: parent.radius
	// 		color: "transparent"
	// 		border { width: 1; color: root.toggled? "transparent" : Globals.Colours.mid; }
	// 	}
	// }
}
