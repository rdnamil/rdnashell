/*-----------------------
--- Bar.qml by andrel ---
-----------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../globals.js" as Globals

Variants { id: root
	property int height: 38
	property list<Item> left: []
	property list<Item> centre: []
	property list<Item> right: []

	model: Quickshell.screens
	delegate: PanelWindow { id: window
		required property var modelData

		screen: modelData
		anchors {
			left: true
			right: true
			top: Globals.Settings.barIsTop
			bottom: !Globals.Settings.barIsTop
		}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:bar"
		implicitHeight: root.height
		color: Globals.Settings.debug? "#80ff0000" : "transparent"

		Rectangle { id: bar
			visible: !Globals.Settings.debug
			anchors.fill: parent
			color: Globals.Colours.dark
			opacity: 0.975

			Rectangle {
				anchors {
					top: window.anchors.top? undefined : parent.top
					bottom: window.anchors.top? parent.bottom : undefined
				}
				width: parent.width
				height: 2
				color: Globals.Colours.light
				opacity: 0.6
			}

			Rectangle {
				anchors {
					top: window.anchors.top? undefined : parent.top
					bottom: window.anchors.top? parent.bottom : undefined
				}
				width: parent.width
				height: 1
				color: Globals.Colours.dark
			}
		}

		Repeater {
			model: [(Edges.Left | (Globals.Settings.barIsTop? Edges.Top : Edges.Bottom)),
			(Edges.Right | (Globals.Settings.barIsTop? Edges.Top : Edges.Bottom))]
			delegate: Rectangle { id: corner
				required property var modelData

				function has(edge) { return (corner.modelData & edge) !== 0; }
				anchors {
					left: corner.has(Edges.Left)? bar.left : undefined
					right: corner.has(Edges.Right)? bar.right : undefined
					top: corner.has(Edges.Top)? bar.top : undefined
					bottom: corner.has(Edges.Bottom)? bar.bottom : undefined
				}
				width: bar.height /4
				height: width
				color: "black"
				layer.enabled: true
				layer.effect: OpacityMask {
					invert: true
					maskSource: Item {
						width: corner.width; height: width;

						Rectangle {
							anchors {
								horizontalCenter: corner.has(Edges.Left)? parent.right : parent.left;
								verticalCenter: corner.has(Edges.Top)? parent.bottom : parent.top;
							}
							width: parent.width *2; height: width; radius: height /2;
						}
					}
				}
			}
		}

		// left items
		Row { id: rowLeft
			anchors.verticalCenter: parent.verticalCenter
			leftPadding: Globals.Controls.padding
			spacing: Globals.Controls.spacing *2
			height: parent.height

			Component.onCompleted: { for (let w of root.left) {
				w.parent = rowLeft;
				w.anchors.verticalCenter = rowLeft.verticalCenter;
			}}
		}

		// center items
		Row { id: rowCentre
			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
			spacing: Globals.Controls.spacing *2
			height: parent.height

			Component.onCompleted: { for (let w of root.centre) {
				w.parent = rowCentre;
				w.anchors.verticalCenter = rowCentre.verticalCenter;
			}}
		}

		// right items
		Row { id: rowRight
			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			rightPadding: Globals.Controls.padding
			spacing: Globals.Controls.spacing *2
			height: parent.height

			Component.onCompleted: { for (let w of root.right) {
				w.parent = rowRight;
				w.anchors.verticalCenter = rowRight.verticalCenter;
			}}
		}
	}
}
