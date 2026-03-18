/*----------------------------------
--- NiriWorkspaces.qml by andrel ---
----------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Ctrl.Widget { id: root
	Rectangle {
		anchors.centerIn: parent
		z: -1
		width: root.icon.width +4; height: root.icon.height +4;
		radius: Globals.Controls.radius *(3 /4) +2
		color: "transparent"
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0.0; color: "#40000000" }
			GradientStop { position: 1.0; color: "#20000000" }
		}
		border { width: 1; color: Qt.alpha(Globals.Colours.light, 0.4); }
	}

	icon: Row {
		spacing: 1;
		Repeater { id: workspaces
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
			delegate: Item { id: workspace
				required property var modelData
				required property int index

				width: Math.max(height, name.width)
				height: 20
				states: [
					State {
						name: "inactive"; when: !workspace.modelData.is_active;

						PropertyChanges { workspace.width: Math.max(height, name.width); }
					},
					State {
						name: "active"; when: workspace.modelData.is_active;

						PropertyChanges {
							workspace.width: Math.max(height, name.width) +windows.count *(6 +Globals.Controls.spacing) +
							(windows.count > 0? Globals.Controls.spacing : 0);
						}
					},
				]
				transitions: Transition { NumberAnimation { property: "width"; duration: 250; }}

				Rectangle {
					anchors.fill: parent
					z: -windows.count
					topLeftRadius: workspace.index > 0? 0 : Globals.Controls.radius *(3 /4); bottomLeftRadius: topLeftRadius;
					topRightRadius: workspace.index < workspaces.count -1? 0 : Globals.Controls.radius *(3 /4); bottomRightRadius: topRightRadius;
					color: {
						if (Globals.Settings.debug) return workspace.modelData.is_active? "green" : "red";
						else return workspace.modelData.is_active? Globals.Colours.light : Globals.Colours.mid;
					}
					opacity: (workspace.modelData.is_active? 0.8 : 0.6 /workspaces.count *(workspace.index +1))
				}

				Text { id: name
					padding: Globals.Controls.spacing
					x: width < parent.width? parent.height /2 -width /2 : 0;y: parent.height /2 -height /2
					text: workspace.modelData.name ?? workspace.modelData.idx
					color: Globals.Colours.text
					font.family: Globals.Font.mono
					font.pointSize: 10
				}

				MouseArea { id: mousearea
					anchors.fill: parent
					hoverEnabled: true
				}

				Repeater { id: windows
					model: ScriptModel { id: model
						values: Service.Niri
						.windows?.filter(w => { // filter for windows in workspace
							return w.workspace_id === workspace.modelData.id;
						})
						.filter(w => !w.is_floating) // filter out floating windows
						.sort ((a ,b) => { // sort in order of positiong in scrolling layout
							if (a.layout.pos_in_scrolling_layout[0] === b.layout.pos_in_scrolling_layout[0]) {
								return a.layout.pos_in_scrolling_layout[1] -b.layout.pos_in_scrolling_layout[1];
							} else return a.layout.pos_in_scrolling_layout[0] -b.layout.pos_in_scrolling_layout[0];
						}) || []
						objectProp: "id"
					}
					delegate: Rectangle { id: window
						required property var modelData
						required property int index

						readonly property bool isActive: window.modelData.id === (workspace.modelData.active_window_id ?? 0)
						readonly property alias trans: trans

						y: workspace.height /2 -height /2
						z: -index
						width: 6; height: width;
						radius: height /2
						color: {
							if (Globals.Settings.debug) return window.isActive? "green" : "red";
							else return window.isActive? Globals.Colours.text : Globals.Colours.dark;
						}
						opacity: workspace.modelData.is_active? 1.0 : 0.0
						transform: Translate { id: trans
							x: {
								if (workspace.modelData.is_active) return workspace.height +window.index *(window.height +Globals.Controls.spacing);
								else return workspace.height /2 -window.width /2;
							}

							Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.InOutCirc; }}
						}

						Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutCirc; }}

						RectangularShadow {
							anchors.fill: parent
							z: parent.z -1
							radius: parent.radius
							blur: parent.width
							opacity: window.isActive? 0.2 : 0.0
						}
					}
				}
			}
		}
	}
}
