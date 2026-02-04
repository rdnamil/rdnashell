/*----------------------------------
--- NiriWorkspaces.qml by andrel ---
----------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services as Service
import "../globals.js" as Globals

Row { id: root
	spacing: Globals.Controls.spacing

	Repeater { id: workspaceRepeater
		model: ScriptModel { id: workspaceModel
			values: Service.Niri.workspaces?.filter(w => { // filter worskpaces on this.output
				return QsWindow.window? w.output === QsWindow.window.screen.name : false;
			})
			 // sort in order of idx
			.sort((a ,b) => {
				return a.idx -b.idx;
			}) || []
			objectProp: "id"
		}
		delegate: Item { id: workspaceDelegate
			required property var modelData

			anchors.verticalCenter: parent.verticalCenter
			width: childrenRect.width
			height: childrenRect.height

			Rectangle {
				anchors.verticalCenter: parent.verticalCenter
				visible: windowRepeater.count == 0 || !workspaceDelegate.modelData.is_active
				width: workspaceDelegate.modelData.is_active? 20 : 8
				height: workspaceDelegate.modelData.is_active? 10 : 8
				radius: height /2
				color: Globals.Colours.mid
			}

			Row {
				anchors.verticalCenter: parent.verticalCenter
				visible: workspaceDelegate.modelData.is_active
				spacing: Globals.Controls.spacing
				width: visible? childrenRect.width : 0

				Repeater { id: windowRepeater
					model: ScriptModel { id: windowModel
						values: Service.Niri.windows?.filter(w => { // filter for windows in workspace
							return w.workspace_id === workspaceDelegate.modelData.id;
						})
						// filter out floating windows
						.filter(w => w.layout.pos_in_scrolling_layout)
						// sort in order of positiong in scrolling layout
						.sort ((a ,b) => {
							if (a.layout.pos_in_scrolling_layout[0] === b.layout.pos_in_scrolling_layout[0]) {
								return a.layout.pos_in_scrolling_layout[1] -b.layout.pos_in_scrolling_layout[1];
							} else return a.layout.pos_in_scrolling_layout[0] -b.layout.pos_in_scrolling_layout[0];
						})
						objectProp: "id"
					}
					delegate: Rectangle { id: windowDelegate
						required property var modelData

						readonly property bool isActiveWindow: windowDelegate.modelData.id === workspaceDelegate.modelData.active_window_id

						anchors.verticalCenter: parent.verticalCenter
						width: windowDelegate.isActiveWindow? 20 : 8
						height: windowDelegate.isActiveWindow? 10 : 8
						radius: height /2
						color: Globals.Colours.text
					}
				}
			}
		}
	}
}
