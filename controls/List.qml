/*------------------------
--- List.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import "../globals.js" as Globals

ScrollView { id: root
	required property var model
	required property Component delegate

	readonly property ListView view: listView
	readonly property MouseArea mouse: mouseArea
	readonly property ScrollBar scrollbar: scrollBar

	signal itemClicked(Item item, MouseEvent mouse)

	onVisibleChanged: if (visible) scrollbar.position = 0.0;
	padding: Globals.Controls.padding /2
	width: 360
	height: Math.min(360, listView.contentHeight +padding *2)
	ScrollBar.vertical: ScrollBar { id: scrollBar
		x: root.width -width /2 -Globals.Controls.padding
		y: root.padding
		height: root.availableHeight
		hoverEnabled: listView.contentHeight > root.height
		contentItem: Rectangle {
			implicitWidth: scrollBar.active? 6 : 4
			radius: width /2
			color: scrollBar.active? Globals.Colours.text : Globals.Colours.mid
			opacity: (scrollBar.active && scrollBar.size < 1.0) ? 0.75 : 0

			Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
			Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
			Behavior on color { ColorAnimation { duration: 250; }}
		}
	}

	ListView { id: listView
		spacing: Globals.Controls.spacing
		model: root.model
		delegate: root.delegate
		clip: true
		boundsBehavior: Flickable.StopAtBounds
		highlightMoveDuration: 0
		highlightFollowsCurrentItem: true
		highlight: Rectangle {
			width: listView.width
			height: listView.currentItem?.height || 0
			radius: Globals.Controls.radius *(3 /4)
			color: Globals.Colours.accent
			opacity: 0.75
		}

		MouseArea { id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			onExited: listView.currentIndex = -1;
			onPositionChanged: (mouse) => {
				const idx = listView.indexAt(mouse.x +listView.contentX, mouse.y +listView.contentY);
				listView.currentIndex = idx;
			}
			onClicked: (mouse) => { if (listView.indexAt(mouse.x +listView.contentX, mouse.y +listView.contentY) !== -1) {
				root.itemClicked(listView.currentItem, mouse);
			}}

			Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; color: "#4000ff00"; }
		}
	}
}
