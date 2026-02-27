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
	property bool colorize

	signal opened()
	signal selected(int index)

	function open() {
		root.opened();
		root.item.visible = true;
	}
	function close() {
		if (root.item) root.item.visible = false;
	}

	onSelected: index => {
		if (index !== -1) root.currentIndex = index;
		item.visible = false;
	}
	width: 240
	Keys.onPressed: event => { if (event.key == Qt.Key_Escape) root.item.visible = false; }
	active: parent.visible
	sourceComponent: Popup { id: popup
		enabled: true
		focus: true
		margins: Globals.Controls.spacing
		width: root.width/* +list.padding *2 -Globals.Controls.spacing*/
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
			view.spacing: 0
			view.currentIndex: -1
			width: popup.width
			onItemClicked: {
				root.selected(list.view.currentIndex);
				// popup.visible = false;
			}
			mouse.onPositionChanged: (mouse) => {
				const idx = view.indexAt(mouse.x +view.contentX, mouse.y +view.contentY);
				const itm = view.itemAtIndex(idx);
				if (!itm.modelData.isSeparator && (itm.modelData.enabled ?? true)) view.currentIndex = idx;
				else view.currentIndex = -1;
			}
			model: root.model
			delegate: RowLayout { id: delegate
				required property var modelData

				width: list.availableWidth
				spacing: Globals.Controls.spacing

				Item {
					visible: delegate.modelData?.isSeparator || false
					Layout.alignment: Qt.AlignHCenter
					Layout.preferredWidth: list.availableWidth -Globals.Controls.padding
					Layout.preferredHeight: Globals.Controls.iconSize

					Rectangle {
						y: parent.height /2 -height /2; width: parent.width; height: 1;
						color: Globals.Colours.light; opacity: 0.4;
					}
				}

				Item {
					visible: list.model.some(e => e.buttonType? e.buttonType !== QsMenuButtonType.None :  false) && !delegate.modelData.isSeparator
					Layout.margins: Globals.Controls.spacing /2
					Layout.leftMargin: Globals.Controls.spacing
					Layout.rightMargin: 0
					Layout.preferredWidth: button.implicitSize
					Layout.preferredHeight: button.implicitSize

					IconImage { id: button
						visible: delegate.modelData?.buttonType !== QsMenuButtonType.None || false
						implicitSize: text.height -Globals.Controls.spacing
						source: switch (delegate.modelData.checkState) {
							case Qt.Unchecked:
								if (delegate.modelData.buttonType === QsMenuButtonType.RadioButton) return Quickshell.iconPath("radio-symbolic");
								else return Quickshell.iconPath("checkbox-symbolic");
							case Qt.PartiallyChecked:
								if (delegate.modelData.buttonType === QsMenuButtonType.RadioButton) return Quickshell.iconPath("radio-mixed-symbolic");
								else return Quickshell.iconPath("checkbox-mixed-symbolic");
							case Qt.Checked:
								if (delegate.modelData.buttonType === QsMenuButtonType.RadioButton) return Quickshell.iconPath("radio-checked-symbolic");
								else return Quickshell.iconPath("checkbox-checked-symbolic");
							default: return '';
						}
						layer.enabled: true
						layer.effect: Colorize {
							hue: Qt.alpha(Globals.Colours.text, 1.0).hslHue
							saturation: Qt.alpha(Globals.Colours.text, 1.0).hslSaturation
							lightness: Qt.alpha(Globals.Colours.text, 1.0).hslLightness
						}
					}
				}

				Item {
					visible: list.model.some(e => e.icon) && !delegate.modelData.isSeparator
					Layout.margins: Globals.Controls.spacing /2
					Layout.leftMargin: Globals.Controls.spacing
					Layout.rightMargin: 0
					Layout.preferredWidth: icon.implicitSize
					Layout.preferredHeight: icon.implicitSize

					IconImage { id: icon
						visible: delegate.modelData.icon? true : false
						implicitSize: text.height -Globals.Controls.spacing
						source: Quickshell.iconPath(delegate.modelData.icon, true) || delegate.modelData?.icon || ''
						layer.enabled: root.colorize
						layer.effect: Colorize {
							hue: Qt.alpha(Globals.Colours.text, 1.0).hslHue
							saturation: Qt.alpha(Globals.Colours.text, 1.0).hslSaturation
							lightness: Qt.alpha(Globals.Colours.text, 1.0).hslLightness
						}
					}
				}

				Text { id: text
					visible: !delegate.modelData.isSeparator
					Layout.margins: Globals.Controls.spacing /2
					Layout.leftMargin: Globals.Controls.spacing
					Layout.rightMargin: Globals.Controls.spacing
					Layout.fillWidth: true
					text: delegate.modelData.text? delegate.modelData.text : ''
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
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		color: Globals.Settings.debug? "#400000ff" : "transparent"
	}
}
