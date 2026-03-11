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
		anchors {
			left: true
			right: true
			bottom: true
		}
		mask: Region {
			x: window.width /2 -width /2; y: window.height -height
			width: window.width *(2 /3); height: 1;

			Region { x: dock.x; y: dock.y +trans.y; width: dock.width; height: dock.height; }
		}
		exclusiveZone: -1
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:dock"
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
				move: Transition { id: moveTrans; SequentialAnimation {
					ScriptAction { script: moveTrans.ViewTransition.item.z = -1; }
					NumberAnimation { property: "x"; duration: 250; easing.type: Easing.InOutCirc; }
					ScriptAction { script: moveTrans.ViewTransition.item.z = 0; }
				}}
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
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					onClicked: (mouse) => {
						function openMenu() {
							popup.model = [
								{"icon":Quickshell.iconPath("utilities-tweak-tool"),"text":"Settings","hasChildren":true,"execute":function(){openSubmenu(["Settings"]);}},
								{"isSeparator":true},
								{"icon":Quickshell.iconPath("applications-accessories"),"text":"Accessories","hasChildren":true,"execute":function(){openSubmenu(["Accessories", "Utility", "Recorder"]);}},
								{"icon":Quickshell.iconPath("applications-utilities"),"text":"Development","hasChildren":true,"execute":function(){openSubmenu(["Development"]);}},
								{"icon":Quickshell.iconPath("applications-education"),"text":"Education","hasChildren":true,"execute":function(){openSubmenu(["Education"]);}},
								{"icon":Quickshell.iconPath("applications-games"),"text":"Games","hasChildren":true,"execute":function(){openSubmenu(["Game"]);}},
								{"icon":Quickshell.iconPath("applications-graphics"),"text":"Graphics","hasChildren":true,"execute":function(){openSubmenu(["Graphics"]);}},
								{"icon":Quickshell.iconPath("applications-internet"),"text":"Internet","hasChildren":true,"execute":function(){openSubmenu(["Internet", "Network", "WebBrowser"]);}},
								{"icon":Quickshell.iconPath("applications-multimedia"),"text":"Multimedia","hasChildren":true,"execute":function(){openSubmenu(["Multimedia", "Player", "AudioVideo"]);}},
								{"icon":Quickshell.iconPath("applications-office"),"text":"Office","hasChildren":true,"execute":function(){openSubmenu(["Office"]);}},
								{"icon":Quickshell.iconPath("applications-science"),"text":"Science","hasChildren":true,"execute":function(){openSubmenu(["Science"]);}},
								{"icon":Quickshell.iconPath("applications-system"),"text":"System","hasChildren":true,"execute":function(){openSubmenu();}},
								{"icon":Quickshell.iconPath("applications-other"),"text":"Other","hasChildren":true,"execute":function(){
									const cats = new Set(["Settings", "Accessories", "Utility", "Recorder", "Development", "Education", "Game", "Graphics", "Internet", "Network", "WebBrowser", "Multimedia", "Player", "AudioVideo", "Office", "Science", "System"]);
									subPopup.model = [
										...DesktopEntries.applications.values
										.filter(a => !a.categories.some(c => cats.has(c)))
										.map(a => ({
											"icon": Quickshell.iconPath(a.name.toLowerCase(), true) || Quickshell.iconPath(a.icon, "application-x-generic"),
											"text": a.name,
											"execute": function() { a.execute(); }
										}))
										.sort((a ,b) => a.text.localeCompare(b.text))
									];
									subPopup.x = backing.width +Globals.Controls.spacing;
									const y = popup.item.list.view.currentItem.y;
									if (y +subPopup.item.height > popup.item.height) subPopup.y = popup.item.height -subPopup.item.height;
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
									.sort((a ,b) => a.text.localeCompare(b.text))
							];
							subPopup.x = backing.width +Globals.Controls.spacing;
							const y = popup.item.list.view.currentItem.y;
							if (y +subPopup.item.height > popup.item.height) subPopup.y = popup.item.height -subPopup.item.height;
							else subPopup.y = y;
							subPopup.open();
						}
						function openPowerOptions() {
							popup.model = [
								{"icon":Quickshell.iconPath("system-lock-screen"),"colorize":true,"text":"Lock","execute":function(){Lockscreen.lock(true)}},
								{"icon":Quickshell.iconPath("system-log-out"),"colorize":true,"text":"Logout","execute":function(){Quickshell.execDetached(['niri','msg','action','quit'])}},
								{"icon":Quickshell.iconPath("system-reboot"),"colorize":true,"text":"Restart","execute":function(){Quickshell.execDetached(['reboot'])}},
								{"icon":Quickshell.iconPath("system-shutdown"),"colorize":true,"text":"Shut down","execute":function(){Quickshell.execDetached(['poweroff'])}}
							]
							menu.open(applications, 120);
						}

						switch (mouse.button) {
							case Qt.LeftButton: openMenu(); break;
							case Qt.RightButton: openPowerOptions(); break;
						}
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

					function movePin(fromIdx, toIdx) {
						if (fromIdx === toIdx) return;
						const item = Service.ShellUtils.pinView.adapter.pins[fromIdx];
						Service.ShellUtils.pinView.adapter.pins.splice(fromIdx, 1);
						Service.ShellUtils.pinView.adapter.pins.splice(toIdx, 0, item);
						Service.ShellUtils.pinView.writeAdapter();
					}

					model: ScriptModel { id: model
						values: [
							...repeater.pins.map(p => [p]),
							...new Map(Service.Niri
							.windows?.filter(w => !repeater.pins.includes(w.app_id))
							.filter(w => { // show only windows that are open on this display
								const ws = Service.Niri.workspaces?.find(ws => ws.id === w.workspace_id)
								return ws?.output === window.screen.name || !ws;
							})
							.map(w => [w["app_id"], w])
							.values() || [])
						]
					}
					delegate: Ctrl.Button { id: delegate
						required property var modelData
						required property int index

						readonly property int count: {
							let c = 0;

							Service.Niri.windows?.forEach(w => {
								if (w.app_id === delegate.modelData[0]) c++;
							});

							return c;
						}
						readonly property bool isFocused: Service.Niri.windows?.some(w => w.app_id === modelData[0] && w.is_focused) || false
						readonly property DesktopEntry entry: DesktopEntries.applications.values.find(a => a.id === modelData[0]) || null

						property int dragStartX

						width: icon.width +Globals.Controls.padding -Globals.Controls.spacing
						height: icon.height +Globals.Controls.padding -Globals.Controls.spacing
						transform: Scale { origin.x: width /2; origin.y: height /2; xScale: delegate.drag.active? 0.9 : 1.0; yScale: xScale; }
						background.visible: !drag.active
						drag.target: repeater.pins.includes(delegate.modelData[0])? delegate : null;
						drag.axis: Drag.XAxis
						drag.minimumX: delegate.index === 0? dragStartX : repeater.itemAt(0).x
						drag.maximumX: windows.x +windows.width -width -Globals.Controls.spacing
						acceptedButtons: Qt.AllButtons
						onPressed: { if (repeater.pins.includes(delegate.modelData[0])) { z = 1; dragStartX = x; dock.hoverCount++; }}
						onReleased: { if (repeater.pins.includes(delegate.modelData[0])) {
							const dragEndX = x; z = 0; x = dragStartX; dock.hoverCount--;

							const targetIndex = Math.round((dragEndX -repeater.itemAt(0).x) / (width +windows.spacing));
							repeater.movePin(index, targetIndex);
						}}
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
									if (delegate.count > 1) {
										popup.model = [...w.map(w => {
											return {
												"icon": Quickshell.iconPath(entry.icon),
												"text": w.title,
												"execute": function() { Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', w.id]); }
											}
										})];
										menu.open(delegate);
									} else if (menu.visible && menu.current === delegate) {
										menu.visible = false;
									} else if (delegate.count > 0) {
										Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', id()]);
										menu.visible = false;
									} else {
										DesktopEntries.applications.values.find(a => a.id === modelData[0]).execute();
										menu.visible = false;
									}
									break;
								case Qt.MiddleButton: w.forEach(w => {
									Quickshell.execDetached(['niri', 'msg', 'action', 'close-window', '--id', w.id])
									});
									menu.visible = false;
									break;
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
												"hasChildren": true,
												// "execute": function() { Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', w.id]); }
												"execute": function() {
													subPopup.model = [
														{"icon":Quickshell.iconPath("focus-windows-symbolic"),"colorize":true,"text":"Focus window","execute":function(){Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', w.id]);}},
														{"icon":Quickshell.iconPath("window-maximize"),"colorize":true,"text":"Maximize window","execute":function(){Quickshell.execDetached(['niri','msg','action','maximize-window-to-edges','--id',w.id])}},
														{"icon":Quickshell.iconPath("window-close"),"colorize": true,"text":"Close window","execute":function(){Quickshell.execDetached(['niri','msg','action','close-window','--id',w.id])}}
													]
													subPopup.x = backing.width +Globals.Controls.spacing;
													const y = popup.item.list.view.currentItem.y;
													if (y +subPopup.item.height > popup.item.height) subPopup.y = popup.item.height -subPopup.item.height;
													else subPopup.y = y;
													subPopup.open();
												}
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
							visible: !parent.drag.active
							z: -1
							width: parent.background.width; height: parent.background.height;
							radius: parent.background.radius
							color: parent.background.color
							border.color: parent.background.border.color
							opacity: delegate.isFocused? 0.25 : 0.0;
						}

						Rectangle { id: countBak
							visible: delegate.count > 1 && !parent.drag.active
							width: Math.max(count.width, height)
							height: count.height
							radius: height /2;
							color: Globals.Colours.success
							border { width: 1; color: Qt.darker(countBak.color, 1.1)}
							// layer.enabled: true
							// layer.effect: DropShadow { samples: 8; horizontalOffset: 2; verticalOffset: 2; color: Qt.alpha("black", 0.25); }

							Text { id: count
								anchors.centerIn: parent
								padding: Globals.Controls.spacing /2
								text: delegate.count
								color: Globals.Colours.text
								font.pointSize: 6
								font.weight: 800
							}
						}

						Rectangle {
							visible: delegate.count > 0 && !parent.drag.active
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
			property Item current

			function open(item, width = 240) {
				subPopup.close();
				menu.current = item;
				popup.width = width;
				backing.x = dock.x +item.x +item.width /2 -backing.width /2;

				if (Service.PopoutManager.whosOpen === item && menu.visible) menu.visible = false;
				else {
					if (!menu.visible) menu.visible = true;
					if (popup.item) popup.item.list.view.currentIndex = -1;
					Service.PopoutManager.whosOpen = item;
				}
			}

			visible: false
			screen: window.screen
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			mask: Region {
				width: menu.width; height: menu.height;

				Region {
					x: dock.x; y: menu.height -dock.height;
					width: dock.width; height: dock.height;
					intersection: Intersection.Subtract
				}
			}
			color: Globals.Settings.debug? "#400000ff" : "transparent"
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			// exclusiveZone: -1
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
				height: (popup.item?.height || 0) +Globals.Controls.padding
				color: Globals.Settings.debug? "#4000ff00" : "transparent"

				Ctrl.PopupMenu { id: popup
					compatibilityMode: true
					onSelected: (index) => {
						// menu.visible = false;
						if (index !== -1) {
							popup.model[index].execute();

							if (!(popup.model[index].hasChildren ?? false)) menu.visible = false;
						} else menu.visible = false;
					}
					onLoaded: popup.item.closePolicy = Popup.CloseOnEscape;

					Rectangle {
						x: -1; y: -1;
						width: parent.width +2; height: (popup.item?.height || 0) +2;
						radius: Globals.Controls.radius
						color: "transparent"
						border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.4); }
						opacity: 0.975
					}

					Rectangle { id: ptr
						x: parent.width /2 -width /2
						y: (popup.item?.height || 0) -height /2 -radius
						width: Math.sqrt((Globals.Controls.padding -radius) **2 *2); height: width;
						radius: 2
						rotation: 315
						color: Globals.Colours.dark
						border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.4); }
						opacity: 0.975
						layer.enabled: true
						layer.effect: OpacityMask { maskSource: Item {
							width: ptr.width; height: ptr.height;

							Rectangle { x: -parent.width /2; y: parent.height /2; width: Math.sqrt(parent.width **2 *2); height: width /2; rotation: 45; }
						}}
					}

					Ctrl.PopupMenu { id: subPopup
						readonly property Transition enterTrans: Transition {}

						compatibilityMode: true
						onSubClose: subPopup.close();
						onSelected: (index) => {
							// menu.visible = false;
							if (index !== -1) {
								subPopup.model[index].execute();
								menu.visible = false;
							}
						}
						onLoaded: {
							subPopup.item.closePolicy = Popup.CloseOnEscape;
							subPopup.item.enter = enterTrans;
						}

						Rectangle {
							visible: subPopup.item?.visible || false
							x: -1; y: -1;
							width: parent.width +2; height: (subPopup.item?.height || 0) +2;
							radius: Globals.Controls.radius
							color: "transparent"
							border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.4); }
						}
					}
				}
			}

			MouseArea { anchors.fill: parent; onClicked: menu.visible = false; }

			Connections {
				target: Service.PopoutManager

				function onWhosOpenChanged() { if (Service.PopoutManager.whosOpen !== menu.current) menu.visible = false; }
			}
		}

		Timer { id: grace
			interval: 1000
			onTriggered: trans.y = window.height;
		}
	}
}
