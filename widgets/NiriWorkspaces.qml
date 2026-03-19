pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Item { id: root
	property list<string> names: []

	width: layout.width; height: layout.height;

	Grid { id: layout
		columnSpacing: Globals.Controls.spacing

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
				height: 20
				onClicked: Quickshell.execDetached(['niri', 'msg', 'action', 'focus-workspace', delegate.modelData.idx])
				effectEnabled: true
				effect: Component { DropShadow {
					samples: 8
					color: delegate.modelData.is_active? "black" : "transparent"

					Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InCirc; }}
				}}
				icon: Text { id: icon
					readonly property color accent: Globals.Colours.accent

					padding: Globals.Controls.padding /2
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

							PropertyChanges { icon.color: Globals.Colours.mid; }
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
