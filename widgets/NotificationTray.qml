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
			const u = model.values.some(n => n && !n.read);

			if (Service.Notifications.dnd) return u? Quickshell.iconPath("notification-disabled-new-symbolic") : Quickshell.iconPath("notification-disabled-symbolic");
			else return u? Quickshell.iconPath("notification-new-symbolic") : Quickshell.iconPath("notification-symbolic");
		}
	}

	Ctrl.Popout { id: popout
		onOpen: {
			model.values.forEach(n => {
				n.read = true;
				// Service.Notifications.expire(n.id);
			});
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
					// onClicked: Service.Notifications.clearall();
					icon: IconImage {
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("edit-clear-history")
					}
					tooltip: "clear all"
				}
			}
			body: Ctrl.List { id: list
				onItemClicked: (item) => { item.modelData.notif.dismiss(); }
				model: ScriptModel { id: model
					values: []
					objectProp: "id"
				}
				delegate: Item { id: delegate
					required property var modelData

					width: list.availableWidth
					height: notifLayout.height +Globals.Controls.spacing *2

					RowLayout { id: notifLayout
						anchors.centerIn: parent
						width: parent.width -Globals.Controls.spacing *2

						Item {
							visible: icon.visible || image.visible
							Layout.preferredWidth: height
							Layout.preferredHeight: notifBodyLayout.height

							// app icon
							Image { id: icon
								readonly property url src: delegate.modelData?.notif?.appIcon || ''
								readonly property url icon: Quickshell.iconPath(delegate.modelData?.notif?.appIcon, true)

								visible: (delegate.modelData?.notif?.appIcon && !image.visible) || false
								anchors.fill: parent
								source: Quickshell.iconPath(delegate.modelData?.notif?.appIcon, true) || delegate.modelData?.notif?.appIcon || ''
								mipmap: true
							}

							// app image
							Image { id: image
								visible: (delegate.modelData?.notif?.image || false) || Globals.Settings.debug
								anchors.fill: parent
								source: delegate.modelData?.notif?.image || ''
								mipmap: true

								// app icon
								IconImage {
									anchors {
										right: parent.right
										rightMargin: -Globals.Controls.spacing
										bottom: parent.bottom
										bottomMargin: -Globals.Controls.spacing
									}
									visible: delegate.modelData?.notif?.appIcon || false
									implicitSize: 14
									source: Quickshell.iconPath(delegate.modelData?.notif?.appIcon, "notifications")
								}

								Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; }
							}
						}

						ColumnLayout { id: notifBodyLayout
							spacing: 0

							RowLayout {
								// app name and summary
								Text {
									Layout.fillWidth: true
									text: `<b>${delegate.modelData?.notif?.appName}</b> ${delegate.modelData?.notif?.summary}`
									color: Globals.Colours.text
									font.pointSize: 8
									font.weight: 600
									wrapMode: Text.Wrap
									maximumLineCount: 2
									elide: Text.ElideRight
								}

								// timestamp
								Text {
									Layout.alignment: Qt.AlignRight | Qt.AlignTop
									text: {
										const d = root.dateTime.date.getTime() -delegate.modelData.timestamp.getTime();

										if (d < 6e4) return "Just now";
										else if (d < 36e5) return `${Math.floor(d /6e4)} min ago`;
										else if (d < 72e5) return "1 hour ago";
										else return Qt.formatDateTime(delegate.modelData.timestamp, "hh:mm");
									}
									color: Globals.Colours.text
									font.pointSize: 8
									font.weight: 600
								}
							}

							// body
							Text {
								Layout.fillWidth: true
								text: delegate.modelData?.notif?.body || null
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

	Connections {
		target: Service.Notifications

		function onNotify(notif) {
			model.values.splice(0, 0, {
				"notif": notif,
				"id": notif.id,
				"timestamp": new Date(),
				"read": false
			});
		}

		function onDismiss(id) {
			while (model.values.some(n => n.id === id)) model.values.splice(model.values.findIndex(n => n.id === id), 1);
		}
	}
}
