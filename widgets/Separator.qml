import QtQuick
import "../globals.js" as Globals

Item { id: root
	width: 2; height: parent.height -Globals.Controls.spacing *2;

	Rectangle {
		width: 1; height: parent.height;
		color: Globals.Colours.light
		opacity: 0.4
	}
}
