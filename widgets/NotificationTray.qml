/*------------------------------------
--- NotificationTray.qml by andrel ---
------------------------------------*/

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Ctrl.Widget { id: root
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: Service.Notifications.dnd? Quickshell.iconPath("notifications-disabled") : Quickshell.iconPath("notification", "notification-inactive")
	}
	onClicked: popout.toggle()

	Ctrl.Popout { id: popout
		content: Ctrl.List { id: list
			onItemClicked: (item, mouse) => { Service.Notifications.dismiss(item.modelData.id); item.remove(); }
			model: Service.Notifications.history
			delegate: Component { Item { id: delegate
				required property var modelData
				required property int index

				property int cachedIndex

				function remove() {
					delegate.ListView.delayRemove = true;
					rmAnim.start();
				}

				width: parent?.width || 0
				height: layout.height +Globals.Controls.padding
				transform: Translate { id: delegateTrans; }

				NumberAnimation { id: rmAnim
					target: delegateTrans; property: "x"; from: 0; to: delegate.width; duration: 250; easing.type: Easing.InOutCirc;
					onFinished: delegate.ListView.delayRemove = false;
				}

				RowLayout { id: layout
					anchors.centerIn: parent
					width: parent.width -Globals.Controls.padding
					// image
					Image {
						visible: (delegate.modelData?.image || false) || Globals.Settings.debug
						Layout.preferredWidth: height
						Layout.fillHeight: true
						source: delegate.modelData?.image || ''

						Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; }
					}

					ColumnLayout {
						spacing: Globals.Controls.spacing

						// app name and summary
						RowLayout {
							IconImage {
								visible: delegate.modelData?.appIcon || false
								implicitSize: Globals.Controls.iconSize
								source: delegate.modelData?.appIcon || ''
							}

							Text {
								Layout.fillWidth: true
								text: `<b>${delegate.modelData?.appName}</b> ${delegate.modelData?.summary}`
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
							text: delegate.modelData?.body || null
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
