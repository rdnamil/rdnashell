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

			Region { x: dock.x; y: dock.y +trans.y; width: dock.width; height: dock.height; }
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

				Rectangle { x: dock.x; y: dock.y +trans.y; width: dock.width; height: dock.height; }
			}}
		}

		MouseArea {
			anchors.bottom: parent.bottom
			width: parent.width
			height: 1
			hoverEnabled: true
			onEntered: {
				trans.y = 0;
				grace.restart();
			}
		}

		Item { id: dock
			property int hoverCount: 0

			onHoverCountChanged: hoverCount > 0? grace.stop() : grace.start();
			x: window.width /2 -width /2
			y: window.height -height
			width: windows.width; height: windows.height +Globals.Controls.padding;
			transform: Translate { id: trans
				y: window.height

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
					property list<string> pins: ["com.mitchellh.ghostty"]

					model: [
						...repeater.pins.map(p => [p]),
						...new Map(Service.Niri
						.windows?.filter(w => !pins.includes(w.app_id))
						.map(w => [w["app_id"], w])
						.values() || [])
						]
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
								case Qt.RightButton:
									const entry = DesktopEntries.applications.values.find(a => a.id === delegate.modelData[0])

									console.log(`Dock: action ids ${entry.actions.map(a => a.id)}`);

									const icon = (id, icon) => { switch (id) {
										case "ew-window": return Quickshell.iconPath("new-window-symbolic");
										case "ew-private-window": return Quickshell.iconPath("view-private-symbolic");
										case "ew-message": return Quickshell.iconPath("mail-message-new-symbolic");
										case "ew-event": return Quickshell.iconPath("view-calendar-upcoming-events");
										case "pen-computer": return Quickshell.iconPath("computer-symbolic");
										case "pen-home": return Quickshell.iconPath("user-home-symbolic");
										case "pen-trash": return Quickshell.iconPath("user-trash-symbolic");
										case "pen-calendar": return Quickshell.iconPath("office-calendar-symbolic");
										default: return Quickshell.iconPath(icon, true);
									}};

									popup.model = [
										{"icon":Quickshell.iconPath(entry.icon),"text":entry.name,"execute":function(){entry.execute();}},
										...entry.actions.map(a => ({"icon":icon(a.id, a.icon),"text":a.name,"execute":function(){a.execute();}})),
										{"isSeparator":true},
										...Service.Niri.windows.filter(w => w.app_id === entry.id).map(w => {
											return {
												"icon": Quickshell.iconPath("focus-windows-symbolic"),
												"text": w.title,
												"execute": function() { Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', w.id]); }
											}
										}),
										{"isSeparator":true},
										{
											"icon": repeater.pins.includes(entry.id)? Quickshell.iconPath("window-unpin") : Quickshell.iconPath("window-pin"),
											"text": repeater.pins.includes(entry.id)? "Unpin from dock" : "Pin to dock",
											"execute": function() {
												if (repeater.pins.includes(entry.id)) repeater.pins.splice(repeater.pins.indexOf(entry.id), 1);
												else repeater.pins.push(entry.id);
											}
										}
									];
									backing.x = dock.x +delegate.x +delegate.width /2 -backing.width /2;
									menu.visible = true;

									break;
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
							border.color: parent.background.border.color
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

		PanelWindow { id: menu
			visible: false
			screen: window.screen
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			color: Globals.Settings.debug? "#400000ff" : "transparent"
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			exclusiveZone: -1
			onVisibleChanged: {
				if (visible) {
					dock.hoverCount++;
					popup.open();
				} else {
					dock.hoverCount--;
					popup.close();
				}
			}

			Rectangle { id: backing
				x: dock.x
				y: menu.height -window.height +dock.y -height
				width: popup.width
				height: popup.item?.height +Globals.Controls.padding || 0
				color: Globals.Settings.debug? "#4000ff00" : "transparent"

				Rectangle {
					x: parent.width /2 -width /2
					y: parent.height -Globals.Controls.padding -height /2
					width: Math.sqrt((Globals.Controls.padding -Globals.Controls.spacing) **2 *2); height: width;
					rotation: 45
					color: Globals.Colours.dark
					opacity: 0.975
				}

				Ctrl.PopupMenu { id: popup
					compatibilityMode: true
					onSelected: (index) => {
						menu.visible = false;
						if (index !== -1) popup.model[index].execute();
					}
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: menu.visible = false;
			}
		}

		Timer { id: grace
			interval: 1000
			onTriggered: trans.y = window.height;
		}
	}
}
