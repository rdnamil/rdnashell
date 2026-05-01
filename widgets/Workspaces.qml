pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.WindowManager
import qs.controls as Ctrl
import "../globals.js" as Globals

Item { id: root
	property list<string> names: []
	property bool wrap

	width: layout.width; height: parent?.height || 0;

	Grid { id: layout
		anchors.centerIn: parent
		columnSpacing: Globals.Controls.spacing
		rows: {
			const h = root.height -Globals.Controls.padding *(4 /3);

			if (h >= 24) return 2;
			else return 1;
		}

		Repeater {
			model: ScriptModel { id: model
				values: [...WindowManager.windowsets]
					.filter(w => w.projection.screens.includes(QsWindow.window?.screen))
					.sort((a, b) => a.coordinates[1] -b.coordinates[1])
				objectProp: "coordinates"
			}
			delegate: Ctrl.Button { id: delegate
				required property Windowset modelData
				required property int index

				width: Math.max(height, icon.width)
				height: Math.max(20, icon.height)
				onEntered: if (root.parent.hasOwnProperty('counter')) root.parent.counter++;
				onExited: if (root.parent.hasOwnProperty('counter')) root.parent.counter--;
				onClicked: if (modelData.canActivate) modelData.activate();
				effectEnabled: true
				effect: Component { DropShadow {
					samples: 12
					color: delegate.modelData.active? "black" : "transparent"

					Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InCirc; }}
				}}
				icon: Text { id: icon
					readonly property color accent: Globals.Colours.accent

					padding: Globals.Controls.spacing
					text: {
						if (Globals.Settings.debug) return `${delegate.modelData.coordinates[0]}x${delegate.modelData.coordinates[1]}`;
						else if (delegate.modelData.id !== '') return delegate.modelData.id;
						else return root.names[delegate.index] ?? (delegate.modelData.coordinates[0] +delegate.modelData.coordinates[1]);
					}
					font.family: Globals.Font.mono
					font.pointSize: 10
					font.weight: 600
					states: [
						State {
							name: "active"; when: delegate.modelData.active;

							PropertyChanges { icon.color: Globals.Colours.text; }
						},
						State {
							name: "hover"; when: delegate.containsMouse;

							PropertyChanges { icon.color: Globals.Colours.text_inactive; }
						},
						State {
							name: "inactive"; when: !delegate.modelData.active;

							PropertyChanges { icon.color:Qt.darker(Globals.Colours.mid, 0.6); }
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

	MouseArea {
		anchors.fill: parent
		onWheel: (wheel) => {
			if (root.wrap) model.values[((model.values.findIndex(w => w.active) +(wheel.angleDelta.y /120)) %model.values.length +model.values.length) %model.values.length].activate();
			else model.values[Math.min(model.values.length, Math.max(0, model.values.findIndex(w => w.active) +(wheel.angleDelta.y /120)))].activate();
		}
	}
}
