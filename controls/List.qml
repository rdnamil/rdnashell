pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import "../globals.js" as Globals

ScrollView { id: root
	required property var model
	required property Component delegate

	readonly property ListView view: listView

	signal itemClicked(Item item, MouseEvent mouse)

	padding: Globals.Controls.padding /2
	width: 480
	height: Math.min(360, listView.contentHeight +padding *2)
	// background: Rectangle { anchors.fill: parent; radius: Globals.Controls.radius; color: Globals.Colours.dark; }
	ScrollBar.vertical: ScrollBar { id: scrollBar
		x: root.width -width /2 -root.padding
		y: root.padding
		height: root.availableHeight
		contentItem: Rectangle {
			implicitWidth: scrollBar.pressed || scrollBar.hovered? 6 : 4
			radius: width /2
			color: scrollBar.pressed? Globals.Colours.text : Globals.Colours.mid
			opacity: root.height < 360? 0 : 0.75

			Behavior on opacity { NumberAnimation { duration: 250; }}
			Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
		}
	}

	ListView { id: listView
		spacing: Globals.Controls.spacing
		model: root.model
		delegate: root.delegate
		clip: true
		currentIndex: mouseArea.containsMouse? listView.indexAt(mouseArea.mouseX, mouseArea.mouseY +listView.contentY) : -1
		boundsBehavior: Flickable.StopAtBounds
		highlightMoveDuration: 0
		highlightFollowsCurrentItem: false
		highlight: Rectangle {
			x: listView.currentItem?.x || 0
			y: listView.currentItem?.y || 0
			width: listView.width
			height: listView.currentItem?.height || 0
			radius: Globals.Controls.radius *(3 /4)
			color: Globals.Colours.accent
			opacity: 0.75
		}

		MouseArea { id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			// onPositionChanged: (mouse) => {
			// 	const idx = listView.indexAt(mouse.x, mouse.y +listView.contentY);
			// 	if (idx !== -1) listView.currentIndex = idx;
			// }
			onClicked: (mouse) => { if (listView.indexAt(mouse.x, mouse.y +listView.contentY) !== -1) {
				root.itemClicked(listView.currentItem, mouse);
			}}
		}
	}
}
