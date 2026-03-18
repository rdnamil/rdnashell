pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.controls as Ctrl
import qs.services as Service
import qs.widgets as Widget
import qs.components as Cmpt
import "../globals.js" as Globals

Ctrl.Button { id: root
	property string fileManager: "thunar"
	property bool centreHorizontally

	height: parent.height
	width: icon.width
	icon: IconImage {
		implicitSize: {
			const h = root.height -Globals.Controls.padding *(4 /3);

			if (h >= 32) return 32;
			else if (h >= 24) return 24;
			else return 16;
		}
		source: Quickshell.iconPath("applications-all-symbolic")
	}
	background {
		anchors { fill: undefined; centerIn: root; }
		width: root.icon.width +Globals.Controls.padding *(2 /3);
		height: root.icon.height +Globals.Controls.padding *(2 /3);
	}
	onClicked: popout.toggle();

	Ctrl.Popout { id: popout
		centreHorizontally: root.centreHorizontally
		stealFocus: true
		onOpen: {
			filters.view.currentIndex = 0;
			applications.view.currentIndex = -1;
			textinput.clear();
		}
		onClose: {
			menu.visible = false;
			fileview.writeAdapter();
		}
		content: Item { id: content
			width: grid.width; height: grid.height;

			Rectangle { // background
				anchors.fill: parent
				radius: Globals.Controls.radius
				color: Globals.Colours.mid

				RectangularShadow {
					x: filters.x
					width: filters.width; height: filters.height;
					radius: parent.radius
					blur: 30
					opacity: 0.4
				}

				Rectangle {
					x: filters.x
					width: filters.width +applications.width; height: filters.height +search.height;
					radius: Globals.Controls.radius
					color: Globals.Colours.base
				}
			}

			GridLayout { id: grid
				rowSpacing: 0
				columnSpacing: 0
				columns: 3
				rows: 2

				Item {
					Layout.alignment: Qt.AlignTop
					Layout.preferredWidth: childrenRect.width; Layout.preferredHeight: childrenRect.height;

					Column { id: col
						padding: Globals.Controls.padding /2
						spacing: Globals.Controls.padding
						width: 160

						Column { // user profile
							x: parent.width /2 -width /2;

							Image {
								anchors.horizontalCenter: parent.horizontalCenter
								width: 64; height: width;
								source: Quickshell.iconPath("system-users")
								mipmap: true
							}

							Text {
								text: Service.ShellUtils.userFullName
								color: Globals.Colours.text
								font.pointSize: 12
								font.weight: 600
							}
						}

						Column { // shortcuts
							Repeater { id: shortcuts
								readonly property string homePath: Quickshell.env("HOME")

								model: ScriptModel {
									values: [
										{"name":"Home","icon":"folder-home","path":shortcuts.homePath},
										{"name":"Downloads","icon":"folder-downloads","path":`${shortcuts.homePath}/Downloads`},
										{"name":"Documents","icon":"folder-documents","path":`${shortcuts.homePath}/Documents`},
										{"name":"Pictures","icon":"folder-pictures","path":`${shortcuts.homePath}/Pictures`},
										{"name":"Music","icon":"folder-music","path":`${shortcuts.homePath}/Music`},
										{"name":"Videos","icon":"folder-videos","path":`${shortcuts.homePath}/Videos`},
									]
								}
								delegate: Ctrl.Button { id: shortcut
									required property var modelData

									height: icon.height +Globals.Controls.spacing

									onClicked:{
										Quickshell.execDetached([root.fileManager, shortcut.modelData.path]);
										popout.isOpen = false;
									}
									icon: RowLayout {
										width: col.width -col.padding *2 -Globals.Controls.padding
										spacing: Globals.Controls.spacing

										IconImage {
											implicitSize: 20
											source: Quickshell.iconPath(shortcut.modelData.icon, "folder")
										}

										Text {
											Layout.alignment: Qt.AlignVCenter
											Layout.fillWidth: true
											text: shortcut.modelData.name
											elide: Text.ElideRight
											color: Globals.Colours.text
											font.pointSize: 10
										}
									}
								}
							}
						}

						Item { id: pins
							width: layout.width; height: layout.height;

							Column { id: layout
								Repeater { id: repeater
									function addRemovePin(id) {
										const pins = Service.ShellUtils.pinView.adapter.pins;

										if (pins.includes(id ?? '')) Service.ShellUtils.pinView.adapter.pins.splice(pins.indexOf(id), 1);
										else if (id) Service.ShellUtils.pinView.adapter.pins.push(id);

										Service.ShellUtils.pinView.writeAdapter();
									}

									function movePin(fromIdx, toIdx) {
										if (fromIdx === toIdx) return;
										const item = Service.ShellUtils.pinView.adapter.pins[fromIdx];
										Service.ShellUtils.pinView.adapter.pins.splice(fromIdx, 1);
										Service.ShellUtils.pinView.adapter.pins.splice(toIdx, 0, item);
										Service.ShellUtils.pinView.writeAdapter();
									}

									model: ScriptModel {
										values: [...Service.ShellUtils.pinView.adapter.pins]
									}
									delegate: Ctrl.Button { id: pin
										required property var modelData
										required property int index

										readonly property DesktopEntry entry: DesktopEntries.applications.values
											.find(a => a.id === pin.modelData) ?? null

										height: icon.height +Globals.Controls.spacing
										icon: RowLayout {
											width: col.width -col.padding *2 -Globals.Controls.padding
											spacing: Globals.Controls.spacing

											IconImage {
												implicitSize: 20
												source: Quickshell.iconPath(pin.entry?.name.toLowerCase(), true) || Quickshell.iconPath(pin.modelData, "application-x-generic")
											}

											Text {
												Layout.alignment: Qt.AlignVCenter
												Layout.fillWidth: true
												text: pin.entry?.name || ''
												elide: Text.ElideRight
												color: Globals.Colours.text
												font.pointSize: 10
											}
										}
										acceptedButtons: Qt.LeftButton | Qt.RightButton
										onClicked: (mouse) => {
											const model = [
												{"icon":"semi-starred","colorize":true,"text":"Remove from favourites","execute":function(){repeater.addRemovePin(pin.entry?.id || null);}},
												{"icon":"process-stop","colorize":true,"text":"Cancel","execute":function(){}}
											];

											switch (mouse.button) {
												case Qt.LeftButton:
													pin.entry?.execute();
													popout.isOpen = false;
													break;
												case Qt.RightButton:
													menu.open(pin, model, pins.x, pins.y, 190, Edges.Right);
													break;
											}
										}
										drag.target: drag
										drag.axis: Drag.YAxis
										onReleased: (mouse) => { if (pin.drag.active) {
											const y = mouse.y +pin.y;

											const prevItem = repeater.itemAt(Math.max(0, pin.index -1));
											const nextItem = repeater.itemAt(Math.min(repeater.count -1, pin.index +1));
											const minThreshhold = prevItem.y +prevItem.height /2;
											const maxThreshhold = nextItem.y +nextItem.height /2;


											if (y < minThreshhold || y > maxThreshhold) {
												let index = 0;
												let item = repeater.itemAt(0);

												while (index < repeater.count && y > item.y +item.height /2) item = repeater.itemAt(++index);

												index > pin.index? repeater.movePin(pin.index, index -1) : repeater.movePin(pin.index, index);
											}
										}}
										onPositionChanged: (mouse) => { if (pin.drag.active) {
											const y = mouse.y +pin.y;

											const prevItem = repeater.itemAt(Math.max(0, pin.index -1));
											const nextItem = repeater.itemAt(Math.min(repeater.count -1, pin.index +1));
											const minThreshhold = prevItem.y +prevItem.height /2;
											const maxThreshhold = nextItem.y +nextItem.height /2;

											let index = 0;

											if ((y <= maxThreshhold || pin.index === repeater.count -1) && (y >= minThreshhold || pin.index === 0)) insertHint.y = pin.y;
											else {
												let item = repeater.itemAt(0);
												while (index < repeater.count && y > item.y +item.height /2) item = repeater.itemAt(++index);

												insertHint.y = (repeater.itemAt(index -1)?.y || 0) +insertHint.height /2 *(repeater.itemAt(index -1)? 1 : -1)
											}
										}}

										Rectangle { id: insertHint
											visible: pin.drag.active
											parent: pins
											width: pin.width; height: pin.height;
											radius: Globals.Controls.radius *(3 /4)
											color: Globals.Settings.debug? "#ff00ff00" : Globals.Colours.accent
											opacity: 0.4
										}

										ShaderEffectSource {
											z: -999
											width: pin.background.width; height: pin.background.height;
											sourceItem: pin.background
											opacity: menu.visible && menu.item === pin? 0.4 : 0.0

											Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}
										}

										ShaderEffectSource { id: drag
											parent: pins
											visible: pin.drag.active
											x: Globals.Controls.padding /2
											y: pin.drag.active? Math.max(-Globals.Controls.spacing, Math.min(pins.height -drag.height +Globals.Controls.spacing, pin.mouseY +pin.y -height /2)) : 0
											z: 999
											width: pin.icon.width; height: pin.icon.height;
											sourceItem: pin.icon
											opacity: 0.5

											MouseArea { anchors.fill: parent; cursorShape: Qt.DragMoveCursor; }

											Rectangle {
												z: -999
												anchors.centerIn: parent
												width: pin.width; height: pin.height;
												radius: Globals.Controls.radius *(3 /4)
												color: Globals.Colours.light
												opacity: 0.8
											}
										}
									}
								}
							}
						}
					}
				}

				Ctrl.List { id: filters
					property bool enabled: !textinput.text.length

					Layout.preferredWidth: 160
					Layout.fillHeight: true
					Layout.minimumHeight: filters.view.contentHeight
					padding: Globals.Controls.padding
					indexCanBeNull: false
					mouse.hoverEnabled: false
					onItemClicked: item => {
						if (filters.enabled) filters.view.currentIndex = item.index;
					}
					model: [
						{"name":"All Applications","icon":"applications-all","categories":[]},
						{"name":"Settings","icon":"applications-system","categories":["Settings"]},
						{"name":"Accessories","icon":"applications-accessories","categories":["Accessories", "Utility", "Recorder"]},
						{"name":"Development","icon":"applications-utilities","categories":["Development"]},
						{"name":"Education","icon":"applications-education","categories":["Education"]},
						{"name":"Games","icon":"applications-games","categories":["Game"]},
						{"name":"Graphics","icon":"applications-graphics","categories":["Graphics"]},
						{"name":"Internet","icon":"applications-internet","categories":["Internet", "Network", "WebBrowser"]},
						{"name":"Multimedia","icon":"applications-multimedia","categories":["Multimedia", "Player", "AudioVideo"]},
						{"name":"Office","icon":"applications-office","categories":["Office"]},
						{"name":"Science","icon":"applications-science","categories":["Science"]}
					]
					delegate: Item { id: filter
						required property var modelData
						required property int index

						width: layout.width; height: layout.height;

						MouseArea {
							anchors.fill: parent
							hoverEnabled: true

							Rectangle {
								visible: parent.containsMouse && filters.enabled
								anchors.fill: parent
								radius: Globals.Controls.radius *(3 /4)
								color: Globals.Colours.accent
								opacity: 0.2
							}
						}

						Row { id: layout
							padding: Globals.Controls.spacing
							spacing: Globals.Controls.spacing
							width: filters.availableWidth

							IconImage {
								implicitSize: 20
								source: Quickshell.iconPath(filter.modelData.icon)
							}

							Text {
								anchors.verticalCenter: parent.verticalCenter
								text: filter.modelData.name
								color: Globals.Colours.text
								font.pointSize: 10
								font.weight: filters.enabled? 400 : 300
								font.italic: !filters.enabled
							}
						}
					}
					opacity: filters.enabled? 1.0 : 0.4
					layer.enabled: true
					layer.effect: MultiEffect {
						saturation: filters.enabled? 0.0 : -1.0
					}
				}

				Ctrl.List { id: applications
					Layout.preferredWidth: 360
					Layout.fillHeight: true
					Layout.preferredHeight: col.height
					padding: Globals.Controls.padding
					leftPadding: 0
					scrollbar.onPositionChanged: menu.visible = false;
					mouse.enabled: !popout.isTransitioning
					mouse.acceptedButtons: Qt.LeftButton | Qt.RightButton
					onItemClicked: (item, mouse) => {
						if ((mouse?.button || Qt.LeftButton) === Qt.LeftButton) {
							// add an etry if none exist
							if (!fileview.adapter.applications.find(a => a.id === item.modelData.id)) {
								fileview.adapter.applications.push({
									"id": item.modelData.id,
									"count": 1,
									"lastOpened": Date.now()
								});
								console.log(`Start menu: Added entry ${item.modelData.id}`);
								// update entry if there's already one
							} else {
								fileview.adapter.applications.find(a => a.id === item.modelData.id).count += 1;
								fileview.adapter.applications.find(a => a.id === item.modelData.id).lastOpened = Date.now();
								console.log(`Start menu: Updated entry ${item.modelData.id}`);
							}
							item.modelData.execute();
							popout.isOpen = false;
						} else {
							const icon = (id, icon) => { switch (id.toLowerCase()) {
								case "new-window": return Quickshell.iconPath("new-window-symbolic");
								case "new-private-window": return Quickshell.iconPath("view-private-symbolic");
								case "new-message": return Quickshell.iconPath("mail-message-new-symbolic");
								case "new-event": return Quickshell.iconPath("view-calendar-upcoming-events");
								case "open-computer": return Quickshell.iconPath("computer-symbolic");
								case "open-home": return Quickshell.iconPath("user-home-symbolic");
								case "open-trash": return Quickshell.iconPath("user-trash-symbolic");
								case "open-calendar": return Quickshell.iconPath("office-calendar-symbolic");
								default: return Quickshell.iconPath(icon, true);
							}};
							const model = [
								{"icon":"starred","colorize":true,"text":"Add to favourites","execute":function(){repeater.addRemovePin(item.modelData.id);}},
								...item.modelData.actions?.map(a => ({"icon":icon(a.id,a.icon),"colorize":true,"text":a.name,"execute":function(){a.execute();}})) || []
							];

							menu.open(item, model, applications.x, applications.view.y -applications.view.contentY);
						}
					}
					model: {
						let list = [...DesktopEntries.applications.values] // list to search from
							.filter(a => !a.noDisplay) // remove entries that request to not be displayed
							.filter((obj, idx, item) => idx === item.findIndex(r => r.id === obj.id)) // dedupe list BUG

						const countMin = Math.min(...fileview.adapter.applications.filter(a => a.count).map(a => a.count));
						const countNormalDevisor = Math.max(...fileview.adapter.applications.filter(a => a.count).map(a => a.count)) -countMin;
						const ageMin = Math.min(...fileview.adapter.applications.filter(a => a.lastOpened).map(a => a.lastOpened)) -Date.now();
						const ageNormalDevisor = Math.max(...fileview.adapter.applications.filter(a => a.lastOpened).map(a => a.lastOpened)) -Date.now() -ageMin
						const recencyWeight = 0.4;

						function calcRelevance(app, now = Date.now()) {
							const countNormal = (app.count -countMin) /countNormalDevisor;
							const ageNormal = (app.lastOpened -now -ageMin) /ageNormalDevisor;
							return recencyWeight *ageNormal +(1 -recencyWeight) *countNormal;
						}

						const relevanceMap = new Map(
							fileview.adapter.applications.map(app => [app.id, calcRelevance(app)])
						);

						if (textinput.text.length > 0) {
							const options = {
								keys: ["id", "name", "genericName", "keywords"],
								threshold: 0.4,
								includeScore: true,
								shouldSort: true
							};
							const fuse = new Fuse(list, options);

							return fuse.search(textinput.text)
								.sort((a, b) => { // return search results sorted based on score and relevance
									const scoreWeight = 0.6;

									const a_App = fileview.adapter.applications.find(app => app.id === a.item.id);
									const b_App = fileview.adapter.applications.find(app => app.id === b.item.id);

									function calcWeightedMatch(app, score, now = Date.now()) {
										const relevance = calcRelevance(app);
										return scoreWeight *(1 -score) +(1 -scoreWeight) *relevance;
									}

									const a_weightedMatch = a_App? calcWeightedMatch(a_App, a.score) : null;
									const b_weightedMatch = b_App? calcWeightedMatch(b_App, b.score) : null;

									if (a_weightedMatch && b_weightedMatch) return b_weightedMatch -a_weightedMatch;
									else if (a_weightedMatch) return -1;
									else if (b_weightedMatch) return 1;
									else return a.score -b.score;
								})
								.map(r => r.item);
						} else return list
							.filter(a => { // filter by category
								const cs = filters.model[filters.view.currentIndex].categories;

								if (cs.length > 0) return a.categories.some(c => cs.includes(c));
								else return true;
							})
							.sort((a, b) => {
								const a_App = fileview.adapter.applications.find(app => app.id === a.id);
								const b_App = fileview.adapter.applications.find(app => app.id === b.id);

								const a_Fav = a_App? a_App.isFavourite : null;
								const b_Fav = b_App? b_App.isFavourite : null;

								// sort by relevance
								const a_Relevance = relevanceMap.get(a.id);
								const b_Relevance = relevanceMap.get(b.id);

								if (a_Relevance && b_Relevance) { return b_Relevance -a_Relevance; }
								else if (a_Relevance) return -1;
								else if (b_Relevance) return 1;

								// sort alphabetically
								return a.name.localeCompare(b.name);
							});
					}
					delegate: RowLayout { id: application
						required property var modelData
						required property int index

						width: applications.availableWidth

						IconImage {
							Layout.leftMargin: Globals.Controls.spacing
							Layout.topMargin: Globals.Controls.spacing /2
							Layout.bottomMargin: Globals.Controls.spacing /2
							implicitSize: 32
							source: Quickshell.iconPath(application.modelData.name.toLowerCase(), true) || Quickshell.iconPath(application.modelData.icon, "application-x-generic")
						}

						ColumnLayout {
							Layout.rightMargin: Globals.Controls.spacing
							spacing: 0

							Text {
								Layout.fillWidth: true
								text: application.modelData.name
								elide: Text.ElideRight
								color: Globals.Colours.text
								font.pointSize: 10
							}

							Text {
								visible: application.modelData.comment
								Layout.fillWidth: true
								text: application.modelData.comment
								color: applications.view.currentIndex === application.index? Globals.Colours.mid :  Globals.Colours.light
								elide: Text.ElideRight
								font.pointSize: 6
								font.letterSpacing: 0.6
							}
						}
					}
				}

				Row { id: power
					Layout.alignment: Qt.AlignHCenter
					padding: Globals.Controls.padding /2
					topPadding: 0
					spacing: Globals.Controls.spacing

					Ctrl.Button { // lock screen
						onClicked: {
							Service.PopoutManager.whosOpen = null;
							Cmpt.Lockscreen.lock(true);
						}
						icon: IconImage {
							implicitSize: 24
							source: Quickshell.iconPath("system-lock-screen")
						}
					}

					Ctrl.Button { // logout
						onClicked: {
							Service.PopoutManager.whosOpen = null;
							Quickshell.execDetached(['niri', 'msg', 'action', 'quit']);
						}
						icon: IconImage {
							implicitSize: 24
							source: Quickshell.iconPath("system-log-out")
						}
					}

					Ctrl.Button { // show power menu
						onClicked: (mouse) => { powerMenu.clicked(mouse); }
						icon: IconImage {
							implicitSize: 24
							source: Quickshell.iconPath("system-shut-down")
						}

						Widget.Power { id: powerMenu
							anchors.fill: parent
							enabled: false
							displayedIcon.opacity: 0.0
						}
					}
				}

				Item { id: search
					Layout.columnSpan: 2
					Layout.fillWidth: true
					Layout.fillHeight: true

					RectangularShadow {
						anchors.fill: textbox
						radius: textbox.radius
						blur: 16
						opacity: 0.4
					}

					Rectangle { id: textbox
						anchors.centerIn: parent
						width: parent.width -Globals.Controls.padding *2; height: childrenRect.height;
						radius: Globals.Controls.radius *(3 /4)
						color: Globals.Colours.dark

						RowLayout {
							spacing: 0
							width: parent.width

							IconImage {
								implicitSize: parent.height
								source: Quickshell.iconPath("search")
							}

							TextInput { id: textinput
								Layout.fillWidth: true
								focus: true
								padding: Globals.Controls.spacing
								clip: true
								color: Globals.Colours.text
								font.pointSize: 10
								cursorDelegate: Rectangle { id: cursor
									visible: textinput.text.length > 0
									width: textinput.cursorRectangle.width
									height: textinput.cursorRectangle.height

									SequentialAnimation on opacity { id: cursorAnim
										running: cursor.visible
										loops: Animation.Infinite
										NumberAnimation { to: 0.0; duration: 500; easing.type: Easing.InCirc; }
										NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.OutCirc; }
									}

									Connections {
										target: textinput

										function onTextEdited() { cursorAnim.restart(); }
									}
								}
								onTextEdited: applications.view.currentIndex = 0;
								onAccepted: applications.itemClicked(applications.view.currentItem, null);
								Keys.onBacktabPressed: applications.view.decrementCurrentIndex();
								Keys.onPressed: (event) => {
									switch (event.key) {
										case Qt.Key_Escape: popout.isOpen = false; break;
										case Qt.Key_Up: applications.view.decrementCurrentIndex(); break;
										case Qt.Key_Tab:
										case Qt.Key_Down: applications.view.incrementCurrentIndex(); break;
									}
								}

								// placeholder text
								Text {
									visible: !parent.text
									padding: parent.padding
									text: "start typing to search..."
									color: Globals.Colours.mid
									font.pointSize: 10
									font.weight: 300
									font.italic: true
								}
							}
						}
					}
				}
			}

			Rectangle { id: menu
				property Item item: null

				function open(item, model, xOffset = 0, yOffset = 0, width = 240, edge = Edges.Bottom) {
					menu.item = item;
					popup.model = model;
					popup.width = width;
					ptr.edge = edge;

					switch (edge) {
						case Edges.Right:
							container.x = item.x +item.width *(3 /4) +xOffset;
							container.y = item.y +item.height /2 -container.height /2 +yOffset;
							break;
						case Edges.Bottom:
							container.x = item.x +item.width /2 -container.width /2 +xOffset;
							container.y = item.y +item.height -Globals.Controls.spacing +yOffset;
							break;
					}

					if (!menu.visible) menu.visible = true;
					if (popup.item.visible) popup.item.list.view.currentIndex = -1;

				}

				visible: false
				anchors.fill: parent
				color: Globals.Settings.debug? "#20ffffff" : "transparent"
				onVisibleChanged: menu.visible? popup.open() : popup.close();

				MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.AllButtons; onClicked: menu.visible = false; }

				Rectangle { id: container
					width: popup.width; height: popup.item?.height || 0;
					color: Globals.Settings.debug? "#20ffffff" : "transparent"

					Ctrl.PopupMenu { id: popup
						active: true
						compatibilityMode: true
						onSelected: (index) => {
							if (index !== -1) popup.model[index].execute();

							menu.visible = false
						}
						onLoaded: popup.item.closePolicy = Popup.CloseOnEscape;

						Rectangle {
							x: -1; y: -1;
							width: parent.width +2; height: (popup.item?.height || 0) +2;
							radius: Globals.Controls.radius
							color: "transparent"
							border { width: 1; color: Qt.alpha(Globals.Colours.accent, 0.4); }
							opacity: 0.975
						}

						Rectangle { id: ptr
							property int edge: Edges.Bottom

							x: edge === Edges.Right? -width /2 +radius : container.width /2 -width /2
							y: edge === Edges.Right? container.height /2 -height /2 : radius -height /2
							width: Math.sqrt((Globals.Controls.padding -radius) **2 *2); height: width;
							radius: 2
							rotation: edge === Edges.Right? 45 : 135
							color: Globals.Colours.dark
							border { width: 1; color: Qt.alpha(Globals.Colours.accent, 0.4); }
							opacity: 0.975
							layer.enabled: true
							layer.effect: OpacityMask { maskSource: Item {
								width: ptr.width; height: ptr.height;

								Rectangle { x: -parent.width /2; y: parent.height /2; width: Math.sqrt(parent.width **2 *2); height: width /2; rotation: 45; }
							}}
						}
					}
				}
			}
		}
	}

	FileView { id: fileview
		path: Qt.resolvedUrl("../components/apps.json")

		JsonAdapter {
			property list<var> applications
		}
	}

	IpcHandler {
		target: "start"

		function open(): void { popout.isOpen = true; }
		function toggle(): void { popout.toggle(); }
	}
}
