/*----------------------------
--- Dropdown.qml by andrel ---
----------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Button { id: root
	property bool compatibilityMode
	property list<var> model: []
	property int currentIndex: model.length > 0? 0 : -1

	signal selected(int index)

	function open() { loader.item.visible = true; }

	width: 320
	height: icon.height
	onSelected: index => { if (index !== -1) root.currentIndex = index; }
	onClicked: root.open();
	icon: RowLayout { id: boxLayout
		width: root.width

		Text {
			Layout.margins: Globals.Controls.spacing
			Layout.leftMargin: Globals.Controls.padding /2
			Layout.fillWidth: true
			text: root.currentIndex !== -1? root.model[root.currentIndex] : ""
			elide: Text.ElideRight
			color: Globals.Colours.text
			font.pointSize: 10
		}

		IconImage {
			Layout.margins: Globals.Controls.spacing
			implicitSize: Globals.Controls.iconSize
			source: Quickshell.iconPath("arrow-down")
		}
	}

	PanelWindow {
		visible: (loader.item?.visible || false) && !root.compatibilityMode
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		color: Globals.Settings.debug? "#40ff0000" : "transparent"
	}

	Loader { id: loader
		Keys.onPressed: event => { if (event.key == Qt.Key_Escape) loader.item.visible = false; }
		active: parent.visible
		sourceComponent: Popup { id: popup
			enabled: true
			focus: true
			margins: Globals.Controls.spacing
			x: -list.padding +Globals.Controls.spacing /2; y: -list.padding;
			width: root.width +list.padding *2 -Globals.Controls.spacing
			height: list.height
			clip: false
			popupType: root.compatibilityMode? Popup.Item : Popup.Native
			background: Item {}
			onAboutToHide: root.selected(-1);

			RectangularShadow {
				visible: root.compatibilityMode
				anchors.fill: list
				radius: Globals.Controls.radius
				blur: 30
				opacity: 0.4
			}

			Rectangle {
				anchors.fill: list
				radius: Globals.Controls.radius
				color: Globals.Colours.dark
			}

			Ctrl.List { id: list
				anchors.centerIn: parent
				width: popup.width
				onItemClicked: {
					root.selected(list.view.currentIndex);
					popup.visible = false;
				}
				model: root.model
				delegate: Text {
					required property var modelData

					padding: Globals.Controls.spacing
					width: list.availableWidth
					text: modelData
					elide: Text.ElideRight
					color: Globals.Colours.text
					font.pointSize: 10
				}
			}
		}
	}
}
