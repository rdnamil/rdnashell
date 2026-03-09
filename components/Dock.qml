/*------------------------
--- Dock.qml by andrel ---
------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Controls
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
				opacity: bak.opacity *0.4
			}

			Rectangle { id: bak
				anchors.fill: windows
				radius: Globals.Controls.radius
				color: Globals.Colours.mid
				opacity: 0.975
				border { width: 1; color: Qt.alpha(Globals.Colours.light, 0.2); }
			}

			Row { id: windows
				padding: Globals.Controls.spacing
				spacing: Globals.Controls.spacing /2

				Ctrl.Button { id: applications
					// visible: false
					onEntered: dock.hoverCount++;
					onExited: dock.hoverCount--;
					width: icon.width +Globals.Controls.padding -Globals.Controls.spacing
					height: icon.height +Globals.Controls.padding -Globals.Controls.spacing
					icon: Item {
						width: appsIcon.width -Globals.Controls.spacing
						height: appsIcon.height

						IconImage { id: appsIcon
							anchors.horizontalCenter: parent.horizontalCenter
							implicitSize: 32
							source: Quickshell.iconPath("applications-all-symbolic");
						}
					}
					onClicked: (mouse) => {
						function openMenu() {
							popup.model = [
								{"icon":Quickshell.iconPath("utilities-tweak-tool"),"text":"Settings","hasChildren":true,"execute":function(){openSubmenu(["Settings"]);}},
								{"icon":Quickshell.iconPath("applications-accessories"),"text":"Accessories","hasChildren":true,"execute":function(){openSubmenu(["Accessories", "Utility"]);}},
								{"icon":Quickshell.iconPath("applications-utilities"),"text":"Development","hasChildren":true,"execute":function(){openSubmenu(["Development"]);}},
								{"icon":Quickshell.iconPath("applications-education"),"text":"Education","hasChildren":true,"execute":function(){openSubmenu(["Education"]);}},
								{"icon":Quickshell.iconPath("applications-games"),"text":"Games","hasChildren":true,"execute":function(){openSubmenu(["Game"]);}},
								{"icon":Quickshell.iconPath("applications-graphics"),"text":"Graphics","hasChildren":true,"execute":function(){openSubmenu(["Graphics"]);}},
								{"icon":Quickshell.iconPath("applications-internet"),"text":"Internet","hasChildren":true,"execute":function(){openSubmenu(["Internet"]);}},
								{"icon":Quickshell.iconPath("applications-multimedia"),"text":"Multimedia","hasChildren":true,"execute":function(){openSubmenu(["Multimedia", "Player"]);}},
								{"icon":Quickshell.iconPath("applications-office"),"text":"Office","hasChildren":true,"execute":function(){openSubmenu(["Office"]);}},
								{"icon":Quickshell.iconPath("applications-science"),"text":"Science","hasChildren":true,"execute":function(){openSubmenu(["Science"]);}},
								{"icon":Quickshell.iconPath("applications-system"),"text":"System","hasChildren":true,"execute":function(){openSubmenu();}},
								{"icon":Quickshell.iconPath("applications-other"),"text":"Other","hasChildren":true,"execute":function(){
									const cats = new Set(["Settings", "Accessories", "Development", "Education", "Game", "Graphics", "Internet", "Multimedia", "Office", "Science", "System"]);
									subPopup.model = [
										...DesktopEntries.applications.values
										.filter(a => !a.categories.some(c => cats.has(c)))
										.map(a => ({
											"icon": Quickshell.iconPath(a.name.toLowerCase(), true) || Quickshell.iconPath(a.icon, "application-x-generic"),
											"text": a.name,
											"execute": function() { a.execute(); }
										}))
									];
									subPopup.x = backing.width +Globals.Controls.spacing;
									const y = popup.item.list.view.currentItem.y -Globals.Controls.spacing;
									if (y +subPopup.item.height > popup.item.height) subPopup.y = popup.item.height -subPopup.item.height -Globals.Controls.spacing;
									else subPopup.y = y;
									subPopup.open();
								}}
							];
							menu.open(applications);
						}
						function openSubmenu(categories = ["System"]) {
							const cats = new Set(categories);
							subPopup.model = [
								...DesktopEntries.applications.values
									.filter(a => a.categories.some(c => cats.has(c)))
									.map(a => ({
										"icon": Quickshell.iconPath(a.name.toLowerCase(), true) || Quickshell.iconPath(a.icon, "application-x-generic"),
										"text": a.name,
										"execute": function() { a.execute(); }
									}))
							];
							subPopup.x = backing.width +Globals.Controls.spacing;
							const y = popup.item.list.view.currentItem.y -Globals.Controls.spacing;
							if (y +subPopup.item.height > popup.item.height) subPopup.y = popup.item.height -subPopup.item.height -Globals.Controls.spacing;
							else subPopup.y = y;
							subPopup.open();
						}

						openMenu();
					}
				}

				Item {
					y: parent.height /2 -height /2
					width: 2; height: parent.height -Globals.Controls.padding;

					Rectangle {
						width: 1; height: parent.height
						color: Globals.Colours.light
						opacity: 0.4
					}
				}

				Repeater { id: repeater
					readonly property list<string> pins: Service.ShellUtils.pinView.adapter.pins

					model: [
						...repeater.pins.map(p => [p]),
						...new Map(Service.Niri
						.windows?.filter(w => !pins.includes(w.app_id))
						.filter(w => { // show only windows that are open on this display
							const ws = Service.Niri.workspaces?.find(ws => ws.id === w.workspace_id)
							return ws?.output === window.screen.name || !ws;
						})
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
						readonly property DesktopEntry entry: DesktopEntries.applications.values.find(a => a.id === modelData[0]) || null

						width: icon.width +Globals.Controls.padding -Globals.Controls.spacing
						height: icon.height +Globals.Controls.padding -Globals.Controls.spacing
						acceptedButtons: Qt.AllButtons
						onClicked: (mouse) => {
							const w = Service.Niri.windows?.filter(w => {
								return w.app_id === modelData[0];
							}) ?? [];
							const id = () => {
								if (w.some(w => w.is_focused)) return w[(w.findIndex(w => w.is_focused) +1) %w.length].id;
								else return w[0].id;
							}
							const entry = DesktopEntries.applications.values.find(a => a.id === delegate.modelData[0]);

							switch (mouse.button) {
								case Qt.LeftButton:
									if (count > 1) {
										popup.model = [...w.map(w => {
											return {
												"icon": Quickshell.iconPath(entry.icon),
												"text": w.title,
												"execute": function() { Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', w.id]); }
											}
										})];
										menu.open(delegate);
										break;
									} else if (count > 0) Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', id()]);
									else DesktopEntries.applications.values.find(a => a.id === modelData[0]).execute();
									break;
								case Qt.MiddleButton: w.forEach(w => {
									Quickshell.execDetached(['niri', 'msg', 'action', 'close-window', '--id', w.id])
								}); break;
								case Qt.RightButton:

									// console.log(`Dock: action ids ${entry.actions.map(a => a.id)}`);

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
										...entry.actions.map(a => ({"icon":icon(a.id, a.icon),"colorize":true,"text":a.name,"execute":function(){a.execute();}})),
										{"isSeparator":true},
										...w.map(w => {
											return {
												"icon": Quickshell.iconPath("focus-windows-symbolic"),
												"colorize": true,
												"text": w.title,
												"execute": function() { Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', w.id]); }
											}
										}),
										{"isSeparator":true},
										{
											"icon": repeater.pins.includes(entry.id)? Quickshell.iconPath("window-unpin") : Quickshell.iconPath("window-pin"),
											"colorize": true,
											"text": repeater.pins.includes(entry.id)? "Unpin from dock" : "Pin to dock",
											"execute": function() {
												if (repeater.pins.includes(entry.id)) Service.ShellUtils.pinView.adapter.pins.splice(repeater.pins.indexOf(entry.id), 1);
												else Service.ShellUtils.pinView.adapter.pins.push(entry.id);

												Service.ShellUtils.pinView.writeAdapter();
											}
										}
									];
									menu.open(delegate);
									break;
							}
						}
						onEntered: dock.hoverCount++;
						onExited: dock.hoverCount--;
						icon: Item {
							width: appIcon.width -Globals.Controls.spacing
							height: appIcon.height

							IconImage { id: appIcon
								anchors.horizontalCenter: parent.horizontalCenter
								implicitSize: 32
								source: Quickshell.iconPath(delegate.entry?.name.toLowerCase(), true) || Quickshell.iconPath(delegate.modelData[0], "application-x-generic")
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

						Rectangle {
							visible: delegate.count > 0
							anchors {
								horizontalCenter: parent.horizontalCenter
								bottom: parent.bottom
							}
							width: delegate.isFocused? 12 : 4; height: 4; radius: height /2;
							color: Globals.Colours.accent
						}
					}
				}
			}
		}

		PanelWindow { id: menu
			function open(item) {
				backing.x = dock.x +item.x +item.width /2 -backing.width /2;
				menu.visible = true;
			}

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
					radius: 2
					rotation: 45
					color: Globals.Colours.dark
					opacity: 0.975
				}

				Ctrl.PopupMenu { id: popup
					compatibilityMode: true
					onSelected: (index) => {
						// menu.visible = false;
						if (index !== -1) {
							popup.model[index].execute();

							if (!(popup.model[index].hasChildren ?? false)) menu.visible = false;
						}
						else menu.visible = false;
					}
					onLoaded: popup.item.closePolicy = Popup.CloseOnEscape;

					Ctrl.PopupMenu { id: subPopup
						compatibilityMode: true
						onSubClose: subPopup.close();
						onSelected: (index) => {
							// menu.visible = false;
							if (index !== -1) subPopup.model[index].execute();
						}
						onLoaded: subPopup.item.closePolicy = Popup.CloseOnEscape;
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
