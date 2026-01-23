/*---------------------------
--- Marquee.qml by andrel ---
---------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import "../globals.js" as Globals

Item { id: root
	required property Item content

	property Item separator: Rectangle {
		width: 4; height: width; radius: height /2;
		color: "white"
	}
	property int spacing: Globals.Controls.spacing
	property bool scrolling: content.width > root.width
	property int speed: 50 // in pixels per second

	width: content.width
	height: content.height
	clip: true

	Row {
		spacing: root.spacing *2
		transform: Translate { id: scroll; }

		Repeater {
			model: 2
			delegate: ShaderEffectSource {
				width: root.content.width; height: root.content.height;
				sourceItem: root.content

				// separator
				ShaderEffectSource {
					visible: root.spacing > width /2
					anchors {
						left: parent.right
						leftMargin: root.spacing -width /2
						verticalCenter: parent.verticalCenter
					}
					width: root.separator.width; height: root.separator.height;
					sourceItem: root.separator
				}
			}
		}
	}

	PropertyAnimation {
		target: scroll
		property: "x"
		from: 0
		to: -(root.content.width +root.spacing *2)
		duration: (root.content.width /root.speed) *1000
		running: root.scrolling
		loops: Animation.Infinite
		onStopped: scroll.x = 0;
	}
}
