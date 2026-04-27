/*-----------------------
--- Bar.qml by andrel ---
-----------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../globals.js" as Globals

Scope { id: root
	property ShellScreen modelData
	property string display

	property int height: 38
	property int anchor: Edges.Top

	property list<Item> left: []
	property list<Item> centre: []
	property list<Item> right: []

	PanelWindow { id: window
		screen: {
			if (root.modelData) return root.modelData;
			else if (root.display) return Quickshell.screens.find(s => s.name === root.display);
		}
		anchors {
			left: true
			right: true
			top: root.anchor === Edges.Top
			bottom: root.anchor === Edges.Bottom
		}
		WlrLayershell.layer: WlrLayer.Top
		WlrLayershell.namespace: "qs:bar"
		BackgroundEffect.blurRegion: Region { item: window.contentItem; }
		implicitHeight: root.height
		color: Globals.Settings.debug? "#80ff0000" : "transparent"

		Rectangle { id: bar
			visible: !Globals.Settings.debug
			anchors.fill: parent
			color: Globals.Colours.base
			opacity: 0.85

			Rectangle {
				anchors {
					top: window.anchors.top? undefined : parent.top
					bottom: window.anchors.top? parent.bottom : undefined
				}
				width: parent.width
				height: 2
				color: Globals.Colours.light
				opacity: 0.2
			}

			Rectangle {
				anchors {
					top: window.anchors.top? undefined : parent.top
					bottom: window.anchors.top? parent.bottom : undefined
				}
				width: parent.width
				height: 1
				color: Globals.Colours.dark
				opacity: 0.2
			}
		}

		Repeater {
			model: [(Edges.Left | (root.anchor === Edges.Top? Edges.Top : Edges.Bottom)),
			(Edges.Right | (root.anchor === Edges.Top? Edges.Top : Edges.Bottom))]
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
			Component.onCompleted: { for (const w of root.left) {
				w.parent = rowLeft;
				w.anchors.verticalCenter = rowLeft.verticalCenter;
				w.children.forEach(c => {
					if (c.hasOwnProperty('anchor')) c.anchor = root.anchor;
				})
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
			Component.onCompleted: { for (const w of root.centre) {
				w.parent = rowCentre;
				w.anchors.verticalCenter = rowCentre.verticalCenter;
				w.children.forEach(c => {
					if (c.hasOwnProperty('anchor')) c.anchor = root.anchor;
				})
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
			Component.onCompleted: { for (const w of root.right) {
				w.parent = rowRight;
				w.anchors.verticalCenter = rowRight.verticalCenter;
				w.children.forEach(c => {
					if (c.hasOwnProperty('anchor')) c.anchor = root.anchor;
				})
			}}
		}
	}

	PanelWindow {
		screen: window.screen
		anchors: window.anchors
		implicitHeight: shadow.blur
		exclusiveZone: 0
		color: "transparent"

		RectangularShadow { id: shadow
			visible: !ToplevelManager.activeToplevel.maximized && ToplevelManager.activeToplevel.screens.includes(window.screen)
			x: parent.width /2 -width /2
			y: -height /2
			width: parent.width
			height: 1
			blur: 12
		}
	}
}
