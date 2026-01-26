import QtQuick
import qs.controls

Widget {
	icon: Rectangle {
		width: 16; height: 16;
		Rectangle { anchors.centerIn: parent; width: 1; height: parent.height; color: "black"; }
		Rectangle { anchors.centerIn: parent; width: parent.width; height: 1; color: "black"; }
	}
	onClicked: popout.toggle();

	Popout { id: popout
		content: Rectangle {
			width: 200
			height: 200
			color: "#8000ff00"
			Rectangle { anchors.centerIn: parent; width: 1; height: parent.height; color: "black"; }
			Rectangle { anchors.centerIn: parent; width: parent.width; height: 1; color: "black"; }
		}
	}
}
