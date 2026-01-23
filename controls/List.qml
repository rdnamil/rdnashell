import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../globals.js" as Globals

ScrollView { id: root
	required property var model
	required property var delegate

	topPadding: Globals.Controls.padding
	bottomPadding: Globals.Controls.padding
	width: 480
	height: Math.min(360)
	background: Rectangle { anchors.fill: parent; radius: Globals.Controls.radius; color: Globals.Colours.dark; }
	ScrollBar.vertical: ScrollBar { id: scrollBar
		anchors { top: parent.top; topMargin: Globals.Controls.spacing /2; }
		x: root.width -width /2 -6
		height: root.availableHeight -Globals.Controls.spacing
		contentItem: Rectangle {
			implicitWidth: scrollBar.pressed || scrollBar.hovered? 6 : 4
			radius: width /2
			color: scrollBar.pressed? Globals.Colours.text : Globals.Colours.mid
			opacity: (scrollBar.active && scrollBar.size < 1.0) ? 0.75 : 0

			Behavior on opacity { NumberAnimation { duration: 250; }}
			Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
		}
	}

	ListView { id: listView
		model: root.model
	}
}
