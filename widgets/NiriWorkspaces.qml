pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Item { id: root
	property list<string> names: []

	width: layout.width; height: parent?.height || 0;

	Grid { id: layout
		anchors.centerIn: parent
		columnSpacing: Globals.Controls.spacing
		rows: {
			const h = root.height -Globals.Controls.padding *(4 /3);

			if (h >= 24) return 2;
			else return 1;
		}

		Repeater { id: repeater
			model: ScriptModel {
				values: Service.Niri
				.workspaces?.filter(w => { // filter worskpaces on this.output
					return QsWindow.window? w.output === QsWindow.window.screen.name : false;
				})
				.sort((a ,b) => { // sort in order of idx
					return a.idx -b.idx;
				}) || []
				objectProp: "id"
			}
			delegate: Ctrl.Button { id: delegate
				required property var modelData
				required property int index

				width: Math.max(height, icon.width)
				height: Math.max(20, icon.height)
				onEntered: if (root.parent.hasOwnProperty('counter')) root.parent.counter++;
				onExited: if (root.parent.hasOwnProperty('counter')) root.parent.counter--;
				onClicked: Quickshell.execDetached(['niri', 'msg', 'action', 'focus-workspace', delegate.modelData.idx])
				effectEnabled: true
				effect: Component { DropShadow {
					samples: 12
					color: delegate.modelData.is_active? "black" : "transparent"

					Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InCirc; }}
				}}
				icon: Text { id: icon
					readonly property color accent: Globals.Colours.accent

					padding: Globals.Controls.spacing
					text: delegate.modelData.name ?? (root.names[delegate.index] ?? delegate.modelData.idx)
					font.family: Globals.Font.mono
					font.pointSize: 10
					font.weight: 600
					states: [
						State {
							name: "active"; when: delegate.modelData.is_active;

							PropertyChanges { icon.color: Globals.Colours.text; }
						},
						State {
							name: "hover"; when: delegate.containsMouse;

							PropertyChanges { icon.color: Globals.Colours.text_inactive; }
						},
						State {
							name: "inactive"; when: !delegate.modelData.is_active;

							PropertyChanges { icon.color:Qt.darker(Globals.Colours.dark, 0.8); }
						}
					]
					transitions: [
						Transition {
							to: "active"; reversible: true;
							ColorAnimation { duration: 150; easing.type: Easing.InCirc; }
						},
						Transition {
							to: "hover"; reversible: true;
							ColorAnimation { alwaysRunToEnd: true; duration: 150; easing.type: Easing.OutCirc; }
						}
					]
				}
			}
		}
	}
}
