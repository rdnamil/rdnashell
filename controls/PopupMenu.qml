pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Loader { id: root
	property list<var> model: []
	property bool compatibilityMode
	property int currentIndex: model.length > 0? 0 : -1

	signal opened()
	signal selected(int index)

	function open() {
		root.opened();
		root.item.visible = true;
	}
	function close() { root.item.visible = false; }

	onSelected: index => { if (index !== -1) root.currentIndex = index; }
	width: 240
	Keys.onPressed: event => { if (event.key == Qt.Key_Escape) root.item.visible = false; }
	active: parent.visible
	sourceComponent: Popup { id: popup
		enabled: true
		focus: true
		margins: Globals.Controls.spacing

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
			delegate: RowLayout { id: delegate
				required property var modelData

				width: list.availableWidth
				spacing: 0

				IconImage {
					visible: delegate.modelData.icon? true : false
					Layout.margins: Globals.Controls.spacing
					Layout.rightMargin: 0
					implicitSize: text.height -Globals.Controls.spacing
					source: Quickshell.iconPath(delegate.modelData.icon)
					layer.enabled: true
					layer.effect: Colorize {
						hue: Qt.alpha(Globals.Colours.light, 1.0).hslHue
						saturation: Qt.alpha(Globals.Colours.light, 1.0).hslSaturation
						lightness: Qt.alpha(Globals.Colours.light, 1.0).hslLightness
					}
				}

				Text { id: text
					Layout.margins: Globals.Controls.spacing
					Layout.fillWidth: true
					// padding: Globals.Controls.spacing
					// width: list.availableWidth
					text: delegate.modelData.text? delegate.modelData.text : ''
					// textFormat: Text.RichText
					elide: Text.ElideRight
					color: Globals.Colours.text
					font.pointSize: 10
				}
			}
		}
	}

	PanelWindow { id: window
		visible: (root.item?.visible || false) && !root.compatibilityMode
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		exclusiveZone: -1
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		color: Globals.Settings.debug? "#400000ff" : "transparent"
	}
}
