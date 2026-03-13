import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Row { id: root
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
					return ws?.output === window.screen.name || !ws;
				})
				.map(w => [w["app_id"], w])
				.values() || [])
			]
		}
		delegate: Ctrl.Button { id: delegate
			required property var modelData

			readonly property var windows: Service.Niri.windows?.filter(w => {
					return w.app_id === modelData[0];
				}) ?? [];
			readonly property int count: {
					let c = 0;

					Service.Niri.windows?.forEach(w => {
						if (w.app_id === delegate.modelData[0]) c++;
					});

						return c;
				}
			readonly property bool isFocused: Service.Niri.windows?.some(w => w.app_id === modelData[0] && w.is_focused) || false
			readonly property DesktopEntry entry: DesktopEntries.applications.values.find(a => a.id === modelData[0]) || null

			width: icon.width +Globals.Controls.spacing *2; height: icon.height +Globals.Controls.spacing *2;
			icon: Row {
				spacing: Globals.Controls.spacing

				Rectangle {
					width: Globals.Controls.iconSize; height: width; radius: 3; color: Globals.Settings.debug? "#ffff0000" : "transparent";

					IconImage {
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath(delegate.entry?.name.toLowerCase(), true) || Quickshell.iconPath(delegate.modelData[0], "application-x-generic")
					}
				}

				Text { id: text
					width: Math.min(implicitWidth, 100)
					text: {
						const t = delegate.windows[0]?.title || '';
						const n = ` — ${delegate.entry.name.split(' ')[0]}`;

						return t? `${t}${t.includes(delegate.entry.name.split(' ')[0])? '' : n}` : delegate.entry.name;
					}
					elide: Text.ElideRight
					color: Globals.Colours.text
					font.pointSize: 8
				}
			}
			tooltip: delegate.windows[0]?.title || delegate.entry.name
			background.radius: 4

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
}
