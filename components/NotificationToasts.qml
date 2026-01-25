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
	property int edges: Edges.Top | Edges.Right

	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		screen: modelData
		anchors {
			left: (root.edges & Edges.Left) !== 0
			right: (root.edges & Edges.Right) !== 0
			top: (root.edges & Edges.Top) !== 0
			bottom: (root.edges & Edges.Bottom) !== 0
		}
		exclusiveZone: 0
		mask: Region {
			x: column.x
			y: column.y +colTrans.y
			width: column.width
			height: column.height
		}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:notifications"
		implicitWidth: column.width +30
		implicitHeight: repeater.count > 0? column.height +30 : 0
		color: Globals.Settings.debug? "#40ff0000" : "transparent"

		Repeater {
			model: repeater.count
			delegate: RectangularShadow {
				required property int index

				anchors.horizontalCenter: parent.horizontalCenter
				y: repeater.itemAt(index).y
				z: -999
				width: repeater.itemAt(index).width
				height: repeater.itemAt(index).height
				blur: 30
				opacity: 0.4 *repeater.itemAt(index).toastOpacity
			}
		}

		Column { id: column
			anchors.horizontalCenter: parent.horizontalCenter
			padding: Globals.Controls.padding
			spacing: Globals.Controls.spacing
			transform: Translate { id: colTrans; }

			Repeater { id: repeater
				model: Service.Notifications.toast
				delegate: Item { id: delegate
					required property var modelData
					required property int index

					readonly property real toastOpacity: toast.opacity

					property bool expired
					property bool dismissed

					visible: true
					z: index *(window.anchors.bottom? 1 : -1)
					width: toast.width
					height: toast.height

					Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}

					ParallelAnimation { id: addAnim
						running: true
						NumberAnimation { target: colTrans; property: "y"; from: window.anchors.bottom? 0: -toast.height -column.spacing; to: 0; duration: 250; easing.type: Easing.OutCirc; }
						NumberAnimation { target: toast; property: "opacity"; from: 0.0; to: 0.975; duration: 250; easing.type: Easing.OutCirc; }
					}

					ParallelAnimation { id: rmAnim
						onStarted: { for (let i = delegate.index; i < repeater.count; i++) {
							repeater.itemAt(i).y -= delegate.height +column.spacing;
						}}
						NumberAnimation { target: toast; property: "opacity"; to: 0; duration: 250; easing.type: Easing.OutCirc; }
						NumberAnimation { target: colTrans; property: "y"; from: 0; to: window.anchors.bottom? toast.height +column.spacing : 0; duration: 250; easing.type: Easing.OutCirc; }
						onFinished: {
							if (delegate.expired) Service.Notifications.toastDestroy(delegate.modelData.id, delegate.dismissed);
							else {
								Service.Notifications.toastResend(delegate.modelData.id);
								addAnim.restart();
							}

							colTrans.y = 0;
						}
					}

					Rectangle { id: toast
						width: 480
						height: toastLayout.height
						color: Globals.Settings.debug? "#4000ff00" : Globals.Colours.dark
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Rectangle {
								width: toast.width
								height: toast.height
								radius: Globals.Controls.radius
							}
						}

						ColumnLayout { id: toastLayout
							width: parent.width
							spacing: 0

							Rectangle {
								Layout.fillWidth: true
								Layout.preferredHeight: 3
								color: Globals.Settings.debug? "#ff0000ff" : Globals.Colours.accent
								transform: Scale { id: expScale; }

								NumberAnimation { id: expAnim
									running: true
									target: expScale; property: "xScale"; from: 1.0; to: 0;
									duration: delegate.modelData?.expireTimeout > 0? delegate.modelData.expireTimeout : 5000;
									onFinished: { delegate.expired = true; rmAnim.restart(); }
								}
							}

							RowLayout {
								Layout.margins: Globals.Controls.padding
								spacing: Globals.Controls.padding

								// image
								Image {
									visible: (delegate.modelData?.image || false) || Globals.Settings.debug
									Layout.preferredWidth: height
									Layout.preferredHeight: bodyLayout.height
									source: delegate.modelData?.image || ''

									Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; }
								}

								ColumnLayout { id: bodyLayout
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
						}
					}

					MouseArea { id: mouse
						visible: expAnim.running
						anchors.fill: parent
						hoverEnabled: true
						onEntered: expAnim.pause();
						onExited: expAnim.resume();
						onClicked: Service.Notifications.dismiss(delegate.modelData.id);
					}

					Connections {
						target: Service.Notifications

						function onDismiss(id) { if (id === delegate.modelData.id) { delegate.dismissed = true; expAnim.complete(); }}
					}

					Connections {
						target: delegate?.modelData || null

						function onSummaryChanged() { expAnim.restart(); rmAnim.restart(); }

						function onBodyChanged() { expAnim.restart(); rmAnim.restart(); }
					}
				}
			}
		}
	}
}
