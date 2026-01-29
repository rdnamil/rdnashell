pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services as Service
import "../globals.js" as Globals

Variants { id: root
	property int edges: Edges.Top

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
		// mask: Region {}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:notifications"
		implicitWidth: 50
		implicitHeight: 100
		color: "#40ff0000"

		// Component.onCompleted: Quickshell.execDetached(['notify-send', 'test', 'test'])

		MouseArea {
			property int count: 1
			anchors.fill: parent
			onClicked: {
				Service.Notifications.dismiss(count);
				// console.log("clicked")
				// count++;
			}
		}

		Column { id: column
			spacing: 5
			y: 10
			// add: Transition { NumberAnimation { property: "y"; duration: 500; }}
			// move: Transition { NumberAnimation { property: "y"; duration: 500; }}

			Repeater { id: repeater
				model: Service.Notifications.toast
				delegate: Item { id: delegate
					required property var index

					readonly property Translate trans: trans

					property bool dismissed

					width: 50
					height: 10

					ShaderEffectSource { id: source
						width: sourceItem.width
						height: sourceItem.height
						live: false
						sourceItem: Rectangle { id: rect
							width: 50
							height: 10
						}
						transform: Translate { id: trans
							Behavior on y {
								SequentialAnimation {
									NumberAnimation { duration: trans.y === 0? 500 : 0; }
									ScriptAction {
										script: {
											for (let i = delegate.index; i < repeater.count; i++) {
												repeater.itemAt(i).trans.y = 0;
											}
										}
									}
									ScriptAction {
										script: {
											if (delegate.dismissed) Service.Notifications.toast.values.splice(delegate.index, 1);
										}
									}
								}
							}
						}
					}

					Connections {
						target: Service.Notifications

						function onDismiss(id) {
							if (id === delegate.index) {
								delegate.dismissed = true;

								for (let i = delegate.index; i < repeater.count; i++) {
									repeater.itemAt(i).trans.y -= delegate.height +column.spacing;
								}
							}
						}
					}
				}
			}
		}
	}
}
