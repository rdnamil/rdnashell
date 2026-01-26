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

	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: Service.Notifications.dnd? Quickshell.iconPath("notifications-disabled") : Quickshell.iconPath("notification", "notification-inactive")
	}
	onClicked: popout.toggle()

	Ctrl.Popout { id: popout
		content: Style.PageLayout {
			header: RowLayout {
				Style.Button {
					Layout.margins: Globals.Controls.padding
					icon: IconImage {
						implicitSize: 16
						source: Quickshell.iconPath("notifications-disabled")
					}
				}
			}
			body: Ctrl.List { id: list
				onItemClicked: (item, mouse) => { Service.Notifications.dismiss(item.modelData.notif.id); item.remove(); }
				model: Service.Notifications.history
				delegate: Component { Item { id: delegate
					required property var modelData
					required property int index

					property int cachedIndex

					function remove() { delegate.ListView.delayRemove = true; rmAnim.start(); }

					width: list.view.width || 0
					height: layout.height +Globals.Controls.padding
					transform: Translate { id: delegateTrans; }

					ParallelAnimation { id: rmAnim
						NumberAnimation { target: delegateTrans; property: "x"; from: 0; to: delegate.width; duration: 250; easing.type: Easing.InOutCirc; }
						NumberAnimation { target: delegate; property: "opacity"; to: 0; duration: 250; easing.type: Easing.OutCirc; }
						onFinished: delegate.ListView.delayRemove = false;
					}

					RowLayout { id: layout
						anchors.centerIn: parent
						width: parent.width -Globals.Controls.padding
						// image
						Image {
							visible: (delegate.modelData?.notif.image || false) || Globals.Settings.debug
							Layout.preferredWidth: height
							Layout.preferredHeight: bodyLayout.height
							source: delegate.modelData?.notif.image || ''

							Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; }
						}

						ColumnLayout { id: bodyLayout
							spacing: Globals.Controls.spacing

							// app name and summary
							RowLayout {
								IconImage {
									visible: delegate.modelData?.notif.appIcon || false
									implicitSize: Globals.Controls.iconSize
									source: delegate.modelData?.notif.appIcon || ''
								}

								Text {
									Layout.fillWidth: true
									text: `<b>${delegate.modelData?.notif.appName}</b> ${delegate.modelData?.notif.summary}`
									color: Globals.Colours.text
									font.pointSize: 8
									font.weight: 600
									wrapMode: Text.Wrap
									maximumLineCount: 2
									elide: Text.ElideRight
								}

								Text {
									readonly property date timestamp: new Date()

									Layout.alignment: Qt.AlignRight
									// text: Qt.formatDateTime(delegate.modelData.timestamp, "hh:mm")
									text: {
										const timeDiff = root.dateTime.date.getTime() -delegate.modelData.timestamp.getTime();

										if (timeDiff < 6e4) return "Just now";
										else if (timeDiff < 36e5) return `${Math.floor(timeDiff /6e4)} min ago`;
										else if (timeDiff < 72e5) return "1 hour ago";
										else return Qt.formatDateTime(timestamp, "hh:mm");
									}
									color: Globals.Colours.text
									font.family: Globals.Font.sans
									font.pointSize: 8
									font.weight: 600
								}
							}

							// body
							Text {
								Layout.fillWidth: true
								text: delegate.modelData?.notif.body || null
								color: Globals.Colours.text
								font.pointSize: 8
								wrapMode: Text.Wrap
								maximumLineCount: 4
								elide: Text.ElideRight
							}
						}
					}
				}}
			}
		}
	}
}
