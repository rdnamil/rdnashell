/*------------------------------
--- PageLayout.qml by andrel ---
------------------------------*/

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "../globals.js" as Globals

ColumnLayout { id: root
	property Item header
	property Item body
	property Item footer

	spacing: 0

	Item { id: headerWrapper
		visible: root.header
		Layout.fillWidth: true
		Layout.minimumWidth: root.header?.width || 0
		Layout.preferredHeight: root.header?.height || null

		RectangularShadow {
			anchors.fill: parent
			blur: 30
			opacity: 0.6
		}

		Rectangle {
			anchors.fill: parent
			topLeftRadius: Globals.Controls.radius
			topRightRadius: Globals.Controls.radius
			color: Globals.Colours.base
		}

		Component.onCompleted: if (root.header) root.header.parent = headerWrapper;
	}

	Item { id: bodyWrapper
		visible: root.body
		Layout.fillWidth: true
		Layout.minimumWidth: root.body?.width || 0
		Layout.preferredHeight: root.body?.height || null
		Layout.minimumHeight: Globals.Controls.radius *3



		Rectangle {
			anchors.fill: parent
			radius: Globals.Controls.radius
			color: Globals.Colours.mid

			Rectangle {
				z: -1
				width: parent.width
				height: parent.radius
				color: Globals.Colours.base
			}

			RectangularShadow {
				anchors.fill: parent
				z: -1
				radius: parent.radius
				blur: 30
				opacity: 0.8
				color: Globals.Colours.dark
			}
		}

		Component.onCompleted: if (root.body) root.body.parent = bodyWrapper;
	}

	Item { id: footerWrapper
		visible: root.footer
		Layout.fillWidth: true
		Layout.minimumWidth: root.footer?.width || 0
		Layout.preferredHeight: root.footer?.height || null

		Rectangle {
			anchors.fill: parent
			bottomLeftRadius: Globals.Controls.radius
			bottomRightRadius: Globals.Controls.radius
			color: Globals.Colours.dark

			Rectangle {
				anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; }
				width: parent.width -Globals.Controls.padding *2; height: 1; color: Globals.Colours.mid;
			}
		}

		Component.onCompleted: if (root.footer) root.footer.parent = footerWrapper;
	}
}
