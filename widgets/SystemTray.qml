/*------------------------
--- Tray.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Wayland
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Item { id: root
	readonly property ShellScreen screen: root.QsWindow.window?.screen || Quickshell.screens[0]

	width: layout.width
	height: parent?.height || 0

	Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; color: "#8000ff00"; }

	Grid { id: layout
		property int anchor
		property int verticalOffset

		anchors.verticalCenter: parent.verticalCenter
		rows: parent.height /(Globals.Controls.spacing
			+(Globals.Controls.iconSize +Globals.Controls.spacing));
		columnSpacing: Globals.Controls.spacing
		rowSpacing: Globals.Controls.spacing

		Repeater { id: repeater
			readonly property list<Item> items: {
				let items = [];

				for (let i = 0; i < repeater.count; i++) items.push(repeater.itemAt(i));

				return items;
			}

			model: SystemTray.items.values
			delegate: Ctrl.Widget { id: delegate
				required property var modelData
				required property int index

				function countUp() { if (root.parent.hasOwnProperty('counter')) root.parent.counter++; }
				function countDown() { if (root.parent.hasOwnProperty('counter')) root.parent.counter--; }

				acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
				onClicked: (mouse) => {
					switch (mouse.button) {
						case Qt.LeftButton:
							if (delegate.modelData.hasMenu) {
								popup.model = menuOpener.children.values
									.filter(e => !e.hasChildren);
								backing.x = (delegate.mapToGlobal(0, 0).x -root.screen.x) +delegate.width /2 -popup.width *(7 /8);

								if (Service.PopoutManager.whosOpen === repeater.itemAt(delegate.index) && menu.visible) Service.PopoutManager.whosOpen = null;
								else {
									if (!menu.visible) menu.visible = true;
									popup.item.list.view.currentIndex = -1;
									menuAnchor.menu = menuOpener.menu;
									Service.PopoutManager.whosOpen = repeater.itemAt(delegate.index);
								}
							} else delegate.modelData.activate(); break;
						case Qt.MiddleButton: delegate.modelData.secondaryActivate(); break;
						case Qt.RightButton: delegate.modelData.activate(); break;
					}
				}
				onWheel: (wheel) => { delegate.modelData.scroll(wheel.angleDelta.y, false); }
				height: icon.height
				tooltip: `${delegate.modelData.tooltipTitle}\n${delegate.modelData.tooltipDescription}`
				icon: IconImage {
					implicitSize: Globals.Controls.iconSize
					source: Quickshell.iconPath(delegate.modelData.id.toLowerCase(), true) || delegate.modelData.icon
				}

				Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; color: "#400000ff"; }

				QsMenuOpener { id: menuOpener; menu: delegate.modelData.menu; }
			}
		}

		PanelWindow { id: menu
			visible: false
			screen: root.screen
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			color: Globals.Settings.debug? "#400000ff" : "transparent"
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			onVisibleChanged: if (menu.visible) {
				popup.open();
				if (root.parent.hasOwnProperty('counter')) root.parent.counter++;
			} else {
				popup.close();
				if (root.parent.hasOwnProperty('counter')) root.parent.counter--;
			}

			Rectangle { id: backing
				y: if (layout.anchor === Edges.Bottom) return menu.height -height -Globals.Controls.padding +(layout.verticalOffset ?? 0);
					else return Globals.Controls.padding -(layout.verticalOffset ?? 0);
				width: popup.width
				height: (popup.item?.height || 0)
				color: Globals.Settings.debug? "#4000ff00" : "transparent"

				Ctrl.PopupMenu { id: popup
					compatibilityMode: true
					onSelected: (index) => {
						if (index !== -1) {
							model[index].triggered();
							menuAnchor.open();
							menuAnchor.close();

							if (!(popup.model[index].hasChildren ?? false)) Service.PopoutManager.whosOpen = null;
						} else menu.visible = false;
					}
					onLoaded: popup.item.closePolicy = Popup.CloseOnEscape;

					Rectangle {
						x: -1; y: -1;
						width: parent.width +2; height: (popup.item?.height || 0) +2;
						radius: Globals.Controls.radius
						color: "transparent"
						border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.4); }
						opacity: 0.975
					}

					Rectangle { id: ptr
						x: parent.width *(7 /8) -width /2
						y: layout.anchor === Edges.Top? radius -height /2 : backing.height -height /2 -radius
						width: Math.sqrt((Globals.Controls.padding -radius) **2 *2); height: width;
						radius: 2
						rotation: layout.anchor === Edges.Top? 135 : 315
						color: Globals.Colours.dark
						border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.4); }
						opacity: popup.item?.opacity || 0.0
						layer.enabled: true
						layer.effect: OpacityMask { maskSource: Item {
							width: ptr.width; height: ptr.height;

							Rectangle { x: -parent.width /2; y: parent.height /2; width: Math.sqrt(parent.width **2 *2); height: width /2; rotation: 45; }
						}}
					}
				}

				QsMenuAnchor { id: menuAnchor; anchor.window: menu; }
			}

			MouseArea { anchors.fill: parent; onClicked: menu.visible = false; }

			Connections {
				target: Service.PopoutManager

				function onWhosOpenChanged() { if (!repeater.items.includes(Service.PopoutManager.whosOpen)) menu.visible = false; }
			}
		}
	}
}
