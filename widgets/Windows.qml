import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Item { id: root
	readonly property ShellScreen screen: root.QsWindow.window?.screen || Quickshell.screens[0]

	width: layout.width; height: layout.height;

	Rectangle { visible: Globals.Settings.debug; anchors.fill: parent; color: "#8000ff00"; }

	Row { id: layout
		required property int anchor

		spacing: Globals.Controls.spacing /2

		Repeater { id: repeater
			readonly property list<string> pins: Service.ShellUtils.pinView.adapter.pins

			model: ScriptModel { id: model
				values: [
					...repeater.pins.map(p => [p]),
					...new Map(Service.Niri
					.windows?.filter(w => !repeater.pins.includes(w.app_id))
					.filter(w => { // show only windows that are open on this display
						const ws = Service.Niri.workspaces?.find(ws => ws.id === w.workspace_id)
						return ws?.output === root.screen.name || !ws;
					})
					.map(w => [w["app_id"], w])
					.values() || [])
				]
			}
			delegate: Ctrl.Button { id: delegate
				required property var modelData

				readonly property var windows: Service.Niri.windows?.filter(w => { // filter only windows that match 'app id'
					return w.app_id === modelData[0];
				})
				.sort((a, b) => b.focus_timestamp.secs -a.focus_timestamp.secs) ?? []; // sort by most recently focused window
				readonly property int count: {
					let c = 0;

					Service.Niri.windows?.forEach(w => {
						if (w.app_id === delegate.modelData[0]) c++;
					});

						return c;
				}
				readonly property bool isFocused: Service.Niri.windows?.some(w => w.app_id === modelData[0] && w.is_focused) || false
				readonly property DesktopEntry entry: DesktopEntries.applications.values.find(a => a.id === modelData[0]) || null
				readonly property string title: {
					const t = delegate.windows[0]?.title || '';
					const n = ` - ${delegate.entry.name.split(' ')[0]}`;

					return t? `${t}${t.includes(delegate.entry.name.split(' ')[0])? '' : n}` : delegate.entry.name;
				}

				width: icon.width +Globals.Controls.spacing *2; height: icon.height +Globals.Controls.spacing *2;
				icon: Row {
					spacing: Globals.Controls.spacing

					Rectangle { // icon
						width: Globals.Controls.iconSize; height: width; radius: 3; color: Globals.Settings.debug? "#ffff0000" : "transparent";

						IconImage {
							implicitSize: Globals.Controls.iconSize
							source: Quickshell.iconPath(delegate.entry?.name.toLowerCase(), true) || Quickshell.iconPath(delegate.modelData[0], "application-x-generic")
						}
					}

					Text { // text
						width: Math.min(implicitWidth, 100)
						text: delegate.title
						elide: Text.ElideRight
						renderType: Text.NativeRendering
						color: Globals.Colours.text
						font.pointSize: 10
					}
				}
				tooltip: title
				background.radius: 4
				acceptedButtons: Qt.AllButtons
				onClicked: (mouse) => {
					const delegateIcon = Quickshell.iconPath(delegate.entry?.name.toLowerCase(), true) || Quickshell.iconPath(delegate.modelData[0], "application-x-generic");
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
					const windows = [...delegate.windows.map(w => {
						return {"icon":delegateIcon,"text":w.title,"execute":function(){Quickshell.execDetached(['niri','msg','action','focus-window','--id', w.id]);}};
					})];
					const options = [
						{"icon":delegateIcon,"text":delegate.entry.name,"execute":function(){entry.execute();}},
						...entry.actions.map(a => ({"icon":icon(a.id,a.icon),"colorize":true,"text":a.name,"execute":function(){a.execute();}})),
						{"isSeparator":true},
						...delegate.windows.map(w => {
							return {"icon":Quickshell.iconPath("window-close"),"colorize":true,"text":`Close - ${w.title}`,"execute":function(){Quickshell.execDetached(['niri','msg','action','close-window','--id',w.id]);}}
						}),
						{"isSeparator":true},
						{
							"icon": repeater.pins.includes(entry.id)? Quickshell.iconPath("window-unpin") : Quickshell.iconPath("window-pin"),
							"colorize": true,
							"text": repeater.pins.includes(entry.id)? "Unpin from bar" : "Pin to bar",
							"execute": function() {
								if (repeater.pins.includes(entry.id)) Service.ShellUtils.pinView.adapter.pins.splice(repeater.pins.indexOf(entry.id), 1);
								else Service.ShellUtils.pinView.adapter.pins.push(entry.id);

								Service.ShellUtils.pinView.writeAdapter();
							}
						}
					]

					switch (mouse.button) {
						case Qt.LeftButton:
							if (delegate.count > 1) menu.open(delegate, windows);
							else if (delegate.count > 0) {
								Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', delegate.windows[0].id]);
								menu.visible = false;

							} else {
								delegate.entry.execute();
								menu.visible = false;
							}
							break;
						case Qt.MiddleButton:
							delegate.windows.forEach(w => {Quickshell.execDetached(['niri', 'msg', 'action', 'close-window', '--id', w.id])});
							menu.visible = false;
							break;
						case Qt.RightButton:
							menu.open(delegate, options);
							break;
					}
				}

				Rectangle { // background
					z: -1
					width: parent.background.width; height: parent.background.height;
					radius: parent.background.radius
					color: parent.background.color
					border.color: parent.background.border.color
					opacity: delegate.isFocused || (menu.visible && Service.PopoutManager.whosOpen === delegate)? 0.25 : 0.0;
				}

				Rectangle { // count indicator
					visible: delegate.count > 1
					width: childrenRect.width; height: childrenRect.height;
					radius: height /2
					color: Globals.Colours.mid
					border { width: 1; color: Qt.alpha(Globals.Colours.light, 0.4); }

					Text {
						padding: Globals.Controls.spacing /2
						width: Math.max(implicitWidth, implicitHeight)
						text: delegate.count
						horizontalAlignment: Text.AlignHCenter
						color: Globals.Colours.text
						font.pointSize: 6
						font.weight: 800
					}
				}
			}
		}

		PanelWindow { id: menu
			function open(item, model = []) {
				const x = root.mapToGlobal(0, 0).x +item.x +item.width /2;

				if (x -(container.width /2 +Globals.Controls.padding) < 0) {
					container.x = Globals.Controls.padding;
					ptr.x = x -container.x;

				} else if (x +(container.width /2 +Globals.Controls.padding) > menu.screen.width) {
					container.x = menu.screen.width -container.width -Globals.Controls.padding;
					ptr.x = x -container.x -ptr.width /2;

				} else {
					container.x = x -container.width /2;
					ptr.x = container.width /2 -ptr.width /2;
				}

				popup.model = model;

				if (Service.PopoutManager.whosOpen === item && menu.visible) menu.visible = false;
				else {
					if (!menu.visible) menu.visible = true;
					if (popup.item.visible) popup.item.list.view.currentIndex = -1;
					Service.PopoutManager.whosOpen = item;
				}
			}

			visible: false
			screen: root.screen
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			color: Globals.Settings.debug? "#400000ff" : "transparent"
			onVisibleChanged: menu.visible? popup.open() : popup.close();

			Rectangle { id: container
				y: layout.anchor === Edges.Bottom? parent.height -height -Globals.Controls.padding : Globals.Controls.padding
				width: popup.width
				height: popup.item?.height || 0
				color: Globals.Settings.debug? "#4000ff00" : "transparent"

				Ctrl.PopupMenu { id: popup
					compatibilityMode: true
					onSelected: (index) => {
						if (index !== -1) {
							popup.model[index].execute();

							if (!(popup.model[index].hasChildren ?? false)) menu.visible = false;
						} else menu.visible = false;
					}
					onLoaded: popup.item.closePolicy = Popup.CloseOnEscape;
				}

				Rectangle {
					x: -1; y: -1;
					width: parent.width +2; height: (popup.item?.height || 0) +2;
					radius: Globals.Controls.radius
					color: "transparent"
					border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.4); }
					opacity: 0.975
				}

				Rectangle { id: ptr
					y: layout.anchor === Edges.Bottom? container.height -height /2 -radius : radius -height /2
					width: Math.sqrt((Globals.Controls.padding -radius) **2 *2); height: width;
					radius: 2
					rotation: layout.anchor === Edges.Bottom? 315 : 135
					color: Globals.Colours.dark
					border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.4); }
					opacity: 0.975
					layer.enabled: true
					layer.effect: OpacityMask { maskSource: Item {
						width: ptr.width; height: ptr.height;

						Rectangle { x: -parent.width /2; y: parent.height /2; width: Math.sqrt(parent.width **2 *2); height: width /2; rotation: 45; }
					}}
				}
			}

			MouseArea { anchors.fill: parent; onClicked: menu.visible = false; }

			Connections { id: connection
				readonly property list<Item> windows: {
					let ws = [];
					for (let i = 0; i < repeater.count; i++) ws.push(repeater.itemAt(i));
					return ws;
				}

				target: Service.PopoutManager

				function onWhosOpenChanged() { if (!connection.windows.includes(Service.PopoutManager.whosOpen)) menu.visible = false; }
			}
		}
	}
}
