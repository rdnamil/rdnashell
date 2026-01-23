import QtQuick
import qs.controls

Widget {
	icon: Rectangle { width: 16; height: 16; }
	onClicked: popout.toggle();

	Popout { id: popout
		content: Rectangle {
			width: 200
			height: 200
			color: "#8000ff00"
		}
	}
}
