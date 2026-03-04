/*------------------------
--- Dock.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Variants { id: root
	property list<Item> widgets: []

	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		screen: modelData
		anchors.bottom: true
		mask: Region {
			x: window.width /2 -width /2; y: window.height -height
			width: window.width *(2 /3); height: 1;

			Region { x: dock.x; y: trans.y; width: dock.width; height: dock.height; }
		}
		exclusiveZone: 0
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:dock"
		implicitWidth: screen.width
		implicitHeight: dock.height +shadow.blur
		color: Globals.Settings.debug? "#40ff0000" : "transparent"

		Rectangle {
			visible: Globals.Settings.debug
			anchors.fill: parent
			color: "#8000ff00"
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Item {
				width: window.width; height: window.height;

				Rectangle {
					x: window.width /2 -width /2; y: window.height -height
					width: window.width *(2 /3); height: 1;
				}

				Rectangle { x: dock.x; y: trans.y; width: dock.width; height: dock.height; }
			}}
		}

		MouseArea {
			anchors.bottom: parent.bottom
			width: parent.width
			height: 1
			hoverEnabled: true
			onEntered: {
				trans.y = shadow.blur;
				grace.restart();
			}
		}

		Item { id: dock
			property int hoverCount: 0

			onHoverCountChanged: hoverCount > 0? grace.stop() : grace.start();
			x: window.width /2 -width /2
			width: windows.width; height: windows.height +Globals.Controls.padding;
			transform: Translate { id: trans
				y: window.height +Globals.Controls.padding

				Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}
			}
			opacity: 0.975

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered: dock.hoverCount++;
				onExited: dock.hoverCount--;
			}

			RectangularShadow { id: shadow
				anchors.fill: windows
				blur: 30
				radius: Globals.Controls.radius
				opacity: dock.opacity *0.4
			}

			Rectangle {
				anchors.fill: windows
				radius: Globals.Controls.radius
				color: Globals.Colours.mid
			}

			Row { id: windows
				padding: Globals.Controls.spacing
				spacing: Globals.Controls.spacing /2

				Ctrl.Button {
					visible: false
					// onClicked: popout.toggle();
					onEntered: dock.hoverCount++;
					onExited: dock.hoverCount--;
					icon: IconImage {
						implicitSize: 24
						source: Quickshell.iconPath("applications-all")
					}
				}

				Repeater { id: repeater
					readonly property list<var> pins: [["com.mitchellh.ghostty"]]

					model: [...repeater.pins,
					...new Map(Service.Niri
					.windows?.sort ((a ,b) => {
						if (a.layout.pos_in_scrolling_layout[0] === b.layout.pos_in_scrolling_layout[0]) {
							return a.layout.pos_in_scrolling_layout[1] -b.layout.pos_in_scrolling_layout[1];
						} else return a.layout.pos_in_scrolling_layout[0] -b.layout.pos_in_scrolling_layout[0];
					})
					.filter(w => w.app_id !== "com.mitchellh.ghostty")
					.map(w => [w["app_id"], w])
					.values() || [])]
					delegate: Ctrl.Button { id: delegate
						required property var modelData

						readonly property int count: {
							let c = 0;

							Service.Niri.windows?.forEach(w => {
								if (w.app_id === delegate.modelData[0]) c++;
							});

								return c;
						}
						readonly property bool isFocused: Service.Niri.windows?.some(w => w.app_id === modelData[0] && w.is_focused) || false

						anchors.verticalCenter: parent?.verticalCenter || undefined
						width: icon.width +Globals.Controls.padding -Globals.Controls.spacing
						height: icon.height +Globals.Controls.padding -Globals.Controls.spacing
						acceptedButtons: Qt.AllButtons
						onClicked: (mouse) => {
							const w = Service.Niri.windows?.filter(w => {
								return w.app_id === modelData[0];
							});

							const id = () => {
								if (w.some(w => w.is_focused)) return w[(w.findIndex(w => w.is_focused) +1) %w.length].id;
								else return w[0].id;
							}

							switch (mouse.button) {
								case Qt.LeftButton:
									if (count > 0) {
										Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', id()]);
									} else DesktopEntries.applications.values.find(a => a.id === modelData[0]).execute();
									break;
								case Qt.MiddleButton: w.forEach(w => {
									Quickshell.execDetached(['niri', 'msg', 'action', 'close-window', '--id', w.id])
								}); break;
								case Qt.RightButton: break;
							}
						}
						onEntered: dock.hoverCount++;
						onExited: dock.hoverCount--;
						icon: Column {
							spacing: Globals.Controls.spacing
							width: appIcon.width -Globals.Controls.spacing

							IconImage { id: appIcon
								anchors.horizontalCenter: parent.horizontalCenter
								implicitSize: 32
								source: Quickshell.iconPath(delegate.modelData[0]);
							}

							Rectangle {
								visible: delegate.count > 0
								anchors.horizontalCenter: parent.horizontalCenter
								width: delegate.isFocused? 12 : 6; height: 4; radius: height /2;
								color: Globals.Colours.accent
							}
						}

						Rectangle {
							z: -1
							width: parent.background.width; height: parent.background.height;
							radius: parent.background.radius
							color: parent.background.color
							opacity: delegate.isFocused? 0.25 : 0.0;
						}

						Rectangle {
							visible: delegate.count > 1
							width: Math.max(childrenRect.width +Globals.Controls.spacing, height)
							height: childrenRect.height +Globals.Controls.spacing
							radius: height /2;
							color: Globals.Colours.success

							Text {
								text: delegate.count
								color: Globals.Colours.text
								font.pointSize: 6
								font.weight: 800
								Component.onCompleted: {
									x = parent.width /2 -width /2;
									y = parent.height /2 -height /2;
								}
							}
						}
					}
				}
			}
		}

		Timer { id: grace
			interval: 1000
			onTriggered: trans.y = window.height +Globals.Controls.padding;
		}
	}
}
