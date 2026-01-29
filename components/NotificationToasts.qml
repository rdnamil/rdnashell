/*--------------------------------------
--- NotificationToasts.qml by andrel ---
--------------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services as Service
import "../globals.js" as Globals

Variants { id: root
	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		screen: modelData
		anchors {
			right: true
			top: true
			// bottom: true
		}
		exclusiveZone: 0
		mask: Region {
			x: view.x; y: view.y
			width: view.width; height: view.height
		}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:notifications"
		color: Globals.Settings.debug? "#40ff0000" : "transparent"
		implicitWidth: 480 +Globals.Controls.padding +30
		implicitHeight: view.height +Globals.Controls.padding +30

		Repeater {
			model: view.count
			delegate: RectangularShadow { id: shadow
				required property int index

				x: view.itemAtIndex(shadow.index).x +view.x
				y: view.itemAtIndex(shadow.index).y +view.y
				z: -999
				width: view.itemAtIndex(shadow.index).width
				height: view.itemAtIndex(shadow.index).height
				blur: 30
				// color: "red"
				opacity: view.itemAtIndex(shadow.index).opacity *0.4
				transform: Translate { x: view.itemAtIndex(shadow.index).trans.x; }
			}
		}

		ListView { id: view
			x: 30
			y: Globals.Controls.padding
			width: parent.width
			height: contentHeight
			spacing: Globals.Controls.spacing
			model: Service.Notifications.toast
			delegate: Item { id: delegate
				required property var modelData

				readonly property Translate trans: delegateTrans

				width: 480
				height: toastLayout.height
				transform: Translate { id: delegateTrans; }
				ListView.onRemove: rmAnim.start();

				ParallelAnimation {
					running: true

					NumberAnimation {
						target: delegate
						property: "opacity"
						from: 0.0; to: 1.0;
						duration: 250; easing.type: Easing.InCirc;
					}
					NumberAnimation {
						target: delegateTrans
						property: "x"; from: window.width -Globals.Controls.padding;
						to: 0
						duration: 250; easing.type: Easing.OutCirc;
					}
				}

				ParallelAnimation { id: rmAnim
					onStarted: delegate.ListView.delayRemove = true;
					onFinished: delegate.ListView.delayRemove = false;

					NumberAnimation {
						target: delegate
						property: "opacity"
						from: 1.0; to: 0.0;
						duration: 250; easing.type: Easing.OutCirc;
					}
					NumberAnimation {
						target: delegateTrans
						property: "x"
						from: 0; to: window.width -Globals.Controls.padding;
						duration: 250; easing.type: Easing.InCirc;
					}
				}

				Rectangle { id: toast
					anchors.fill: toastLayout
					radius: Globals.Controls.radius
					color: Globals.Settings.debug? "#4000ff00" : Globals.Colours.dark
				}

				ColumnLayout { id: toastLayout
					width: parent.width
					spacing: 0
					layer.enabled: true
					layer.effect: OpacityMask {
						maskSource: Rectangle {
							width: toastLayout.width
							height: toastLayout.height
							radius: Globals.Controls.radius
						}
					}

					// expiration timer
					Rectangle {
						Layout.fillWidth: true
						Layout.preferredHeight: 3
						color: Globals.Settings.debug? "#ff0000ff" : Globals.Colours.accent
						transform: Scale { id: expScale; }

						NumberAnimation { id: expAnim
							running: true
							target: expScale; property: "xScale"; from: 1.0; to: 0;
							duration: delegate.modelData.notif?.expireTimeout > 0? delegate.modelData.notif.expireTimeout : 5000;
							onFinished: Service.Notifications.expire(delegate.modelData.notif.id);
						}
					}

					RowLayout {
						Layout.margins: Globals.Controls.padding
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

				MouseArea {
					visible: expAnim.running
					anchors.fill: parent
					hoverEnabled: true
					onEntered: expAnim.pause();
					onExited: expAnim.resume();
					onClicked: Service.Notifications.dismiss(delegate.modelData.notif.id);
				}
			}
		}
	}
}
