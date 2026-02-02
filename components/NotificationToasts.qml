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
		}
		mask: Region {
			x: 30
			y: Globals.Controls.padding
			width: window.width -30 -Globals.Controls.padding
			height: window.height -30 -Globals.Controls.padding
		}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:notifications"
		implicitWidth: Math.min(...model.values.map((elem, index) => { return repeater.itemAt(index).width })) +30 +Globals.Controls.padding;
		implicitHeight: {
			let h = Globals.Controls.padding +30

			model.values.forEach((elem, index) => {
				h += repeater.itemAt(index).height +Globals.Controls.spacing
			});

			return h;
		}
		color: Globals.Settings.debug? "#40ff0000" : "transparent"

		Repeater {
			model: repeater.count
			delegate: RectangularShadow { id: shadow
				required property int index

				x: repeater.itemAt(index).x
				z: -999
				width: repeater.itemAt(index).width
				height: repeater.itemAt(index).height
				radius: Globals.Controls.radius
				transform: Translate { y: repeater.itemAt(shadow.index).toastTrans.y; }
				blur: 30
				opacity: repeater.itemAt(index).opacity *0.4
			}
		}

		Repeater { id: repeater
			model: ScriptModel { id: model
				values: []
				objectProp: "id"
			}
			delegate: Rectangle { id: delegate
				required property var modelData
				required property int index

				readonly property Translate toastTrans: toastTrans
				readonly property int delta: timer.height +Globals.Controls.padding

				function add(id, height) {
					if (delegate.modelData.id === id) addAnim.start();
					else toastTrans.y += height +Globals.Controls.spacing;
				}

				function remove(id, height) {
					toastTrans.y -= height +Globals.Controls.spacing;
					if (delegate.modelData.id === id) rmAnim.start();
				}

				x: 30
				z: -index
				width: 480; height: toastLayout.height +delta +Globals.Controls.padding;
				transform: Translate { id: toastTrans
					Behavior on y { NumberAnimation { id: toastTransBehavior; duration: 250; easing.type: Easing.OutCirc; }}
				}
				color: Globals.Colours.base
				layer.enabled: true
				layer.effect: OpacityMask { maskSource: Rectangle {
					width: delegate.width; height: delegate.height;
					radius: Globals.Controls.radius
				}}

				Rectangle { id: timer
					width: parent.width
					height: 3
					transform: Scale { id: timerScale; }
					color: Globals.Colours.accent

					NumberAnimation { id: timerAnim
						onFinished: Service.Notifications.expire(delegate.modelData.id);
						running: true
						target: timerScale
						property: "xScale"
						to: 0.0
						duration: 5000
					}
				}

				RowLayout { id: toastLayout
					y: delegate.delta
					x: parent.width /2 -width /2
					width: parent.width -Globals.Controls.padding *2
					spacing: Globals.Controls.padding

					Item {
						visible: icon.visible || image.visible
						Layout.preferredWidth: height
						Layout.preferredHeight: toastBodyLayout.height

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

					ColumnLayout { id: toastBodyLayout
						spacing: 0

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

				MouseArea {
					visible: !rmAnim.running
					anchors.fill: parent
					hoverEnabled: true
					onEntered: timerAnim.pause(); // pause the expiration timer while hovering over toast
					onExited: timerAnim.resume();
					onClicked: if (!toastTransBehavior.running) delegate.modelData.notif.dismiss();
				}

				ParallelAnimation { id: addAnim
					NumberAnimation {
						target: delegate
						property: "opacity"
						from: 0.0
						to: 0.975
						duration: 250
						easing.type: Easing.InOutCirc;
					}
					NumberAnimation {
						target: toastTrans
						property: "y"
						from: Globals.Controls.padding -delegate.height -Globals.Controls.spacing
						to: Globals.Controls.padding
						duration: 250
						easing.type: Easing.OutCirc;
					}
				}

				NumberAnimation { id: rmAnim
					onFinished: model.values.splice(delegate.index, 1);
					target: delegate
					property: "opacity"
					to: 0.0
					duration: 250
					easing.type: Easing.InOutCirc;
				}
			}
		}

		Connections {
			target: Service.Notifications

			function onNotify(notif) {
				if (!Service.Notifications.dnd) {
					model.values.splice(0, 0, {
						"notif": notif,
						"id": notif.id
					});

					for (let i = 0; i < repeater.count; i++) {
						repeater.itemAt(i).add(notif.id, repeater.itemAt(0).height);
					}
				}
			}

			function onExpire(id) {
				const idx = model.values.findIndex(n => n.id === id);

				if (idx !== -1) for (let i = idx; i < repeater.count; i++) {
					repeater.itemAt(i).remove(id, repeater.itemAt(idx).height);
				}
			}
		}
	}
}
