/*------------------------
--- Tray.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
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
				Service.PopoutManager.whosOpen = null;

				switch (mouse.button) {
					case Qt.LeftButton:
						delegate.modelData.activate(); break;
					case Qt.MiddleButton:
						delegate.modelData.secondaryActivate(); break;
					case Qt.RightButton:
						popup.x = mouse.x -Globals.Controls.radius *2 *0.1464;
						popup.y = mouse.y -Globals.Controls.radius *2 *0.1464;
						popup.open();
						break;
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
				}
			}
		}
	}
}
