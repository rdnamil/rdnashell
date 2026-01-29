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
		source: {
			const un = Service.Notifications.history.values.some(n => n && !n.read);

			if (Service.Notifications.dnd) return un? Quickshell.iconPath("notification-disabled-new-symbolic") : Quickshell.iconPath("notification-disabled-symbolic");
			else return un? Quickshell.iconPath("notification-new-symbolic") : Quickshell.iconPath("notification-symbolic");
		}
	}

	Ctrl.Popout { id: popout
		onOpen: {
			Service.Notifications.history.values.forEach(n => n.read = true);
			Service.Notifications.clearallToasts();
		}
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
			body: Ctrl.List {
				onItemClicked: (item, mouse) => { Service.Notifications.dismiss(item.modelData.notif.id); }
				model: Service.Notifications.history
				delegate: Item { id: delegate
					required property var modelData

					width: 480 -Globals.Controls.spacing *2
					height: toastLayout.height +Globals.Controls.spacing *2

					RowLayout { id: toastLayout
						anchors.centerIn: parent
						width: parent.width  -Globals.Controls.spacing *2
						spacing: Globals.Controls.padding

						// icon
						Image {
							visible: (delegate.modelData.notif?.image || false) || Globals.Settings.debug
							Layout.preferredWidth: height
							Layout.preferredHeight: toastBodyLayout.height
							source: delegate.modelData.notif?.image || ''
							mipmap: true

							Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; }
						}

						ColumnLayout { id: toastBodyLayout
							spacing: Globals.Controls.spacing

							RowLayout {
								// app icon
								IconImage {
									visible: delegate.modelData.notif?.appIcon || false
									implicitSize: Globals.Controls.iconSize
									source: Quickshell.iconPath(delegate.modelData.notif?.appIcon, "notifications")
								}

								// app name and summary
								Text {
									Layout.fillWidth: true
									text: `<b>${delegate.modelData.notif?.appName}</b> ${delegate.modelData.notif?.summary}`
									color: Globals.Colours.text
									font.pointSize: 8
									font.weight: 600
									wrapMode: Text.Wrap
									maximumLineCount: 2
									elide: Text.ElideRight
								}
							}

							// body
							Text {
								Layout.fillWidth: true
								text: delegate.modelData.notif?.body || null
								color: Globals.Colours.text
								font.pointSize: 8
								wrapMode: Text.Wrap
								maximumLineCount: 4
								elide: Text.ElideRight
							}
						}
					}
				}
			}
		}
	}
}
