import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../globals.js" as Globals

Item { id: root
	ScrollView { id: scrollview
		anchors.fill: parent
		padding: Globals.Controls.padding

		ColumnLayout { id: layout
			width: scrollview.availableWidth

			Rectangle {
				Layout.fillWidth: true
				Layout.minimumWidth: 480
				Layout.preferredHeight: width *(9 /16)
				radius: Globals.Controls.radius *(3 /4)
				color: Globals.Colours.dark

				Rectangle { id: previewContainer
					x: parent.width /2 -width /2
					y: (parent.height -height) *(1 /3)
					width: parent.width -24
					height: parent.height -36
					layer.enabled: true
					layer.effect: OpacityMask { maskSource: Rectangle {
							width: previewContainer.width
							height: previewContainer.height
							radius: 2
					}}
				}
			}
		}
	}
}
