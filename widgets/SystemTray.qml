/*------------------------
--- Tray.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Row { id: root
	spacing: Globals.Controls.spacing

	Repeater { id: repeater
		model: SystemTray.items.values
		delegate: Ctrl.Widget { id: delegate
			required property var modelData

			acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
			// onClicked: delegate.modelData.activate()
			onClicked: (mouse) => {
				Service.PopoutManager.whosOpen = popup;

				switch (mouse.button) {
					case Qt.LeftButton:
						// popup.x = mouse.x -Globals.Controls.radius *2 *0.1464;
						// popup.y = mouse.y -Globals.Controls.radius *2 *0.1464;
						popup.x = delegate.width -popup.width +arrow.width /2 -arrow.radius;
						popup.y = root.height +Globals.Controls.padding;
						popup.selected(-1);
						break;
					case Qt.MiddleButton: delegate.modelData.secondaryActivate(); break;
					case Qt.RightButton: delegate.modelData.activate(); break;
				}
			}
			onWheel: (wheel) => { delegate.modelData.scroll(wheel.angleDelta.y, false); }
			height: root.parent.height
			tooltip: `${delegate.modelData.tooltipTitle}\n${delegate.modelData.tooltipDescription}`
			icon: IconImage {
				implicitSize: Globals.Controls.iconSize
				source: Quickshell.iconPath(delegate.modelData.id.toLowerCase(), true) || delegate.modelData.icon
			}

			QsMenuOpener { id: menuOpener; menu: delegate.modelData.menu; }

			Ctrl.PopupMenu { id: popup
				model: menuOpener.children.values
					.filter(e => !e.hasChildren)
				onSelected: (index) => {
					model[index]?.triggered();
					// popup.close();
					!(popup.item?.visible || false)? popup.open() : popup.close();
				}
				onLoaded: popup.item.closePolicy = Popup.CloseOnEscape;
				window.mask: Region { y: root.height; width: popup.window.width; height: popup.window.height -root.height; }

				Rectangle { id: arrow
					parent: popup.wrapper;
					x: parent.width -parent.offset -Math.sqrt(width **2 *2)
					y: parent.offset -height /2 +radius
					width: Math.sqrt((Globals.Controls.padding -radius) **2 *2); height: width;
					radius: 2
					rotation: 45
					color: Globals.Colours.dark
				}

				Connections {
					target: Service.PopoutManager

					function onWhosOpenChanged() { if (Service.PopoutManager.whosOpen !== popup) popup.close(); }
				}
			}
		}
	}
}
