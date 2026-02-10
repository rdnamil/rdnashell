pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services as Service
import "../globals.js" as Globals

Variants { id: root
	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		// visible: false
		screen: modelData
		anchors {
			left: true
			right: true
			bottom: true
		}
		exclusiveZone: 0
		mask: Region {
			x: window.width /2 -width /2
			y: window.height -height
			height: Math.max(1, dock.height -dockTrans.y)
			width: dock.width
		}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:dock"
		implicitHeight: dock.height +30
		color: Globals.Controls.debug? "#80ff0000" : "transparent"

		MouseArea { id: hotArea
			anchors.bottom: parent.bottom
			width: parent.width
			height: 1
			hoverEnabled: true
			onEntered: dockTrans.y = 0;
		}

		Item { id: dock
			x: parent.width /2 -width /2
			y: 30
			width: view.contentWidth +Globals.Controls.padding
			height: 64
			transform: Translate { id: dockTrans
				y: dock.height

				Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}
			}

			RectangularShadow {
				anchors.fill: background
				radius: background.radius
				blur: 30
				opacity: background.opacity *0.4
			}

			Rectangle { id: background
				width: parent.width
				height: parent.height -Globals.Controls.padding
				radius: Globals.Controls.radius
				color: Globals.Colours.mid
				opacity: 0.975
			}

			ListView { id: view
				anchors.centerIn: background
				height: background.height -Globals.Controls.padding
				width: contentWidth
				orientation: ListView.Horizontal
				spacing: Globals.Controls.spacing *2
				currentIndex: view.model.values?.findIndex(w => {
						const thisWorkspace = Service.Niri
							.workspaces?.find(ws => ws.output === window.screen.name && ws.is_active);

						return w.id === thisWorkspace.active_window_id;
					})
				highlightFollowsCurrentItem: false
				highlight: Rectangle {
					x: view.currentItem?.x -Globals.Controls.spacing /2 || 0
					y: view.currentItem?.y -Globals.Controls.spacing /2 || 0
					width: view.currentItem?.width +Globals.Controls.spacing || 0
					height: view.currentItem?.height +Globals.Controls.spacing || 0
					radius: Globals.Controls.radius *(3 /4)
					color: Globals.Colours.accent
					opacity: 0.75
				}
				model: ScriptModel {
					values: Service.Niri
						// filter for windows on current workspace
						.windows?.filter(w => {
							const thisWorkspace = Service.Niri
							.workspaces?.find(ws => ws.output === window.screen.name && ws.is_active);

							return thisWorkspace? w.workspace_id === thisWorkspace.id : false;
						})
						// filter out floating windows
						.filter(w => !w.is_floating)
						// sort in order of positiong in scrolling layout
						.sort ((a ,b) => {
							if (a.layout.pos_in_scrolling_layout[0] === b.layout.pos_in_scrolling_layout[0]) {
								return a.layout.pos_in_scrolling_layout[1] -b.layout.pos_in_scrolling_layout[1];
							} else return a.layout.pos_in_scrolling_layout[0] -b.layout.pos_in_scrolling_layout[0];
						}) || []
					objectProp: "id"
				}
				delegate: Item { id: delegate
					required property var modelData

					function activate() { Quickshell.execDetached(['niri', 'msg', 'action', 'focus-window', '--id', modelData.id]); }

					width: view.height -Globals.Controls.spacing *2; height: view.height;

					IconImage {
						implicitSize: parent.width
						source: Quickshell.iconPath(delegate.modelData.app_id)
					}

					Rectangle {
						anchors {
							horizontalCenter: parent.horizontalCenter
							bottom: parent.bottom
							bottomMargin: Globals.Controls.spacing /2
						}
						width: Globals.Controls.spacing *2; height: width /2;
						radius: height /2
						color: Globals.Colours.text
					}
				}
			}

			MouseArea { id: mousearea
				anchors.fill: parent
				hoverEnabled: true
				onEntered: grace.stop();
				onExited: {
					grace.restart();
					tooltipTimer.stop();
					tooltipTimer.interval = 2000;
					tooltip.visible = false;
				}
				onPositionChanged: {
					if (view.indexAt(mouseX -view.x, mouseY -view.y) !== -1) {
						if (!tooltip.visible) tooltipTimer.restart();
					} else {
						tooltipTimer.stop();
						tooltip.visible = false;
					}
				}
				onClicked: {
					// console.log(view.indexAt(mouseX -view.x, mouseY -view.y))
					if (view.indexAt(mouseX -view.x, mouseY -view.y) !== -1)
						view.itemAt(mouseX -view.x, mouseY -view.y).activate();
				}

				Timer { id: tooltipTimer
					interval: 2000
					onTriggered: {
						tooltip.setRect();
						tooltip.visible = true;
						interval = 100;
					}
				}

				PopupWindow { id: tooltip
					function setRect() {
						const itm = view.itemAt(mousearea.mouseX -view.x, mousearea.mouseY -view.y);
						tooltip.anchor.rect.x = itm.x +view.x +itm.width /2 -width /2;
						tooltip.anchor.rect.y = -height -Globals.Controls.spacing;
					}

					anchor.item: background
					mask: Region {}
					implicitWidth: text.width
					implicitHeight: text.height
					color: "transparent"

					Rectangle {
						anchors.fill: text;
						radius: 2
						color: Globals.Colours.base
						border { width: 1; color: Globals.Colours.mid; }
						opacity: 0.975
					}

					Text { id: text
						padding: Globals.Controls.spacing
						text: {
							if (view.indexAt(mousearea.mouseX -view.x, mousearea.mouseY -view.y) !== -1)
								view.itemAt(mousearea.mouseX -view.x, mousearea.mouseY -view.y).modelData.title;
							else return '';
						}
						font.pointSize: 8
						font.italic: true
						color: Globals.Colours.light
					}
				}
			}

			Timer { id: grace
				interval: 1000
				onTriggered: dockTrans.y = height;
			}
		}
	}
}
