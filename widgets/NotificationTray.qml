/*------------------------------------
--- NotificationTray.qml by andrel ---
------------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	readonly property SystemClock dateTime: SystemClock { id: clock
		precision: SystemClock.Seconds
	}

	acceptedButtons: Qt.LeftButton | Qt.MiddleButton
	onClicked: (mouse) => {
		switch (mouse.button) {
			case Qt.LeftButton:
				popout.toggle();
				break;
			case Qt.MiddleButton:
				Service.Notifications.dnd = !Service.Notifications.dnd;
				break;
		}
	}
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		// source: Service.Notifications.dnd? Quickshell.iconPath("notifications-disabled") : Quickshell.iconPath("notification", "notification-inactive")
		source: {
			const un = Service.Notifications.history.values.some(n => n && !n.read);

			if (Service.Notifications.dnd) return un? Quickshell.iconPath("notification-disabled-new-symbolic") : Quickshell.iconPath("notification-disabled-symbolic");
			else return un? Quickshell.iconPath("notification-new-symbolic") : Quickshell.iconPath("notification-symbolic");
		}
	}

	Ctrl.Popout { id: popout
		onOpen: Service.Notifications.history.values.forEach(n => n.read = true);
		content: Style.PageLayout { id: content
			header: RowLayout {
				width: content.width

				Row {
					Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
					Layout.margins: Globals.Controls.spacing
					clip: false

					IconImage {
						anchors.verticalCenter: parent.verticalCenter
						width: implicitSize +Globals.Controls.padding
						implicitSize: 16
						source: Quickshell.iconPath("notifications-disabled")
					}

					Ctrl.Switch {
						toggle: Service.Notifications.dnd
						onClicked: Service.Notifications.dnd = !Service.Notifications.dnd;
					}
				}

				Ctrl.Button {
					Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
					Layout.margins: Globals.Controls.spacing
					onClicked: Service.Notifications.clearall();
					icon: IconImage {
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("edit-clear-history")
					}
					tooltip: "clear all"
				}
			}
			body: Item {
				width: 480
				height: 10
			}
		}
	}
}
