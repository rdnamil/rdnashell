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
	readonly property alias wrapper: shadowWrapper
	readonly property alias window: window

	property list<var> model: []
	property bool compatibilityMode
	property int currentIndex: model.length > 0? 0 : -1
	property bool colorize
	property bool isOpen

	signal opened()
	signal selected(int index)
	signal subClose()

	function open() {
		root.isOpen = true;
		root.opened();
		root.item.visible = true;
	}
	function close() {
		root.isOpen = false;
		if (root.item) root.item.visible = false;
	}

	onSelected: index => {
		if (index !== -1) root.currentIndex = index;
		// item.visible = false;
	}
	width: 240
	height: parent.height
	Keys.onPressed: event => { if (event.key == Qt.Key_Escape) root.item.visible = false; }
	active: parent.visible
	sourceComponent: Popup { id: popup
		readonly property alias list: list

		enabled: true
		focus: true
		width: root.width
		height: list.height
		clip: false
		popupType: root.compatibilityMode? Popup.Item : Popup.Native
		background: Item {}
		onAboutToShow: {
			shadowWindow.anchor.rect.x = x -shadow.blur;
			shadowWindow.anchor.rect.y = y -shadow.blur;
		}
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
			// border { width: 1; color: Qt.alpha(Globals.Colours.base, 0.2); }
			opacity: 0.975
		}

		Ctrl.List { id: list
			anchors.centerIn: parent
			view.spacing: 0
			view.currentIndex: -1
			view.onCurrentIndexChanged: timer.restart();
			width: popup.width
			onItemClicked: (item) => {
				// root.selected(list.view.currentIndex);
				root.selected(list.view.currentItem.modelData.idx);
			}
			mouse.onPositionChanged: (mouse) => {
				const idx = view.indexAt(mouse.x +view.contentX, mouse.y +view.contentY);
				const itm = view.itemAtIndex(idx);
				if (!itm.modelData.isSeparator && (itm.modelData.enabled ?? true)) view.currentIndex = idx;
				else view.currentIndex = -1;
			}
			model: [...root.model]
				.map((e, i) => Object.assign({}, e, { idx: i })) // append root.model idx to entry
				.filter((e, i, arr) => { // filter out some seperators
					const prev = arr[i - 1];
					const next = arr[i + 1];

					if ((i === 0 || i === arr.length - 1) && e.isSeparator) return false;
					if (e.isSeparator && (prev?.isSeparator || next == null)) return false;

					return true;
				})
				.filter(e => Object.keys(e).length) // filter out empty objects
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
						implicitSize: text.height -Globals.Controls.spacing /2
						source: Quickshell.iconPath(delegate.modelData.icon, true) || delegate.modelData?.icon || ''
						layer.enabled: (delegate.modelData.colorize ?? false) || root.colorize
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

				IconImage {
					visible: delegate.modelData.hasChildren ?? false
					Layout.margins: Globals.Controls.spacing /2
					Layout.leftMargin: 0
					Layout.rightMargin: Globals.Controls.spacing
					implicitSize: text.height
					source: Quickshell.iconPath("arrow-right")
					layer.enabled: true
					layer.effect: Colorize {
						hue: Qt.alpha(Globals.Colours.text, 1.0).hslHue
						saturation: Qt.alpha(Globals.Colours.text, 1.0).hslSaturation
						lightness: Qt.alpha(Globals.Colours.text, 1.0).hslLightness
					}
				}
			}
		}

		Timer { id: timer
			interval: 250
			onTriggered: if (list.view.currentIndex !== -1) {
				if (list.view.currentItem.modelData.hasChildren) root.selected(list.view.currentItem.modelData.idx);
			} else root.subClose();
		}
	}

	PopupWindow { id: shadowWindow
		visible: (root.item?.visible || false) && !root.compatibilityMode
		anchor {
			item: root
			adjustment: PopupAdjustment.None
		}
		implicitWidth: root.width +shadow.blur *2
		implicitHeight: root.item?.height +shadow.blur *2 ||  0
		mask: Region {}
		color: Globals.Settings.debug? "#40ff0000" : "transparent"

		Item { id: shadowWrapper
			readonly property int offset: shadow.blur

			anchors.fill: parent
			layer.enabled: true
			layer.effect: OpacityMask {
				invert: true
				maskSource: Item {
					width: shadowWrapper.width; height: shadowWrapper.height;

					Rectangle {
						anchors.centerIn: parent
						width: root.width; height: root.item?.height || 0;
						radius: shadow.radius
					}
				}
			}

			RectangularShadow { id: shadow
				x: blur; y: blur;
				width: parent.width -blur *2; height: parent.height -blur *2;
				radius: Globals.Controls.radius
				blur: 30
				// color: "green"
				opacity: 0.4 *0.975
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
