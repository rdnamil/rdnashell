/*------------------------------
--- PageLayout.qml by andrel ---
------------------------------*/

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../globals.js" as Globals

Item { id: root
	property Item header
	property Item body
	property Item footer

	width: layout.width
	height: layout.height
	layer.enabled: true
	layer.effect: OpacityMask { maskSource: Rectangle {
		width: root.width; height: root.height;
		radius: Globals.Controls.radius
	}}

	Rectangle {
		anchors.fill: layout
		radius: Globals.Controls.radius
		color: Globals.Colours.base
		border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.2); }
	}

	ColumnLayout { id: layout
		spacing: 0

		Item { id: headerWrapper
			visible: root.header
			Layout.fillWidth: true
			Layout.minimumWidth: root.header?.width || 0
			Layout.preferredHeight: root.header?.height || null

			Component.onCompleted: if (root.header) root.header.parent = headerWrapper;
		}

		Item { id: bodyWrapper
			z: 1
			visible: root.body
			Layout.fillWidth: true
			Layout.minimumWidth: root.body?.width || 0
			Layout.preferredHeight: root.body?.height || null
			Layout.minimumHeight: root.body? Globals.Controls.radius *3 : 0

			Rectangle {
				anchors.fill: parent
				radius: Globals.Controls.radius
				color: Globals.Colours.mid
				border { width: 1; color: Qt.alpha(Globals.Colours.light, 0.2); }

				RectangularShadow {
					anchors.fill: parent
					z: -1
					radius: parent.radius
					blur: 30
					opacity: (root.header || root.footer)? 0.4 : 0.0
				}
			}

			Component.onCompleted: if (root.body) root.body.parent = bodyWrapper;
		}

		Item { id: footerWrapper
			visible: root.footer
			Layout.fillWidth: true
			Layout.minimumWidth: root.footer?.width || 0
			Layout.preferredHeight: root.footer?.height || null

			Component.onCompleted: if (root.footer) root.footer.parent = footerWrapper;
		}
	}
}
