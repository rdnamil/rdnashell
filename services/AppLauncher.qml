pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals
import "../fuse.js" as FuseLib

Singleton { id: root
	function init() {}

	Loader { id: loader
		active: true
		sourceComponent: PanelWindow {
			// anchors.top: true
			// margins.top: screen.height *(1 /3) -layout.header.height /2 -30
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			// mask: Region {}
			exclusiveZone: -1
			focusable: true
			WlrLayershell.layer: WlrLayer.Overlay
			// WlrLayershell.namespace: "qs:launcher"
			// color: "#40ff0000"
			color: "transparent"
			implicitWidth: layout.width +60
 			implicitHeight: layout.height +60

 			RectangularShadow {
				anchors.fill: layout
				radius: Globals.Controls.radius
				blur: 30
				opacity: 0.4
			}

			MouseArea {
				anchors.fill: parent
				onClicked: loader.active = false;
			}

			Style.PageLayout { id: layout
				x: parent.width /2 -width /2
				y: parent.height *(1 /3) -header.height /2
				opacity: 0.4
				header: Item {
					width: list.width
					height: textInputLayout.height +Globals.Controls.padding *2

					RectangularShadow {
						anchors.fill: textInputLayout
						radius: Globals.Controls.radius *(3 /4)
						blur: 10
						opacity: 0.4
					}

					Rectangle {
						anchors.fill: textInputLayout
						radius: Globals.Controls.radius *(3 /4)
						color: Globals.Colours.dark
						border { width: 1; color: Globals.Colours.base; }
					}

					RowLayout { id: textInputLayout
						anchors.centerIn: parent
						width: parent.width -Globals.Controls.padding *2

						IconImage {
							Layout.margins: Globals.Controls.spacing
							implicitSize: Globals.Controls.iconSize
							source: Quickshell.iconPath("search")
						}

						TextInput {
							Layout.fillWidth: true
							focus: true
							// text: "test"
							color: Globals.Colours.text
							font.pointSize: 10
							onAccepted: list.itemClicked(list.view.currentItem, null);

							Text {
								visible: !parent.text
								leftPadding: Globals.Controls.spacing
								text: "start typing to search..."
								color: Globals.Colours.base
								font.pointSize: 10
								font.italic: true
							}
						}
					}
				}
				body: Ctrl.List { id: list
					model: DesktopEntries.applications.values
					.filter(a => !a.noDisplay)
					delegate: Item { id: delegate
						required property var modelData

						width: list.width
						height: appLayout.height +Globals.Controls.spacing

						RowLayout { id: appLayout
							anchors.centerIn: parent
							width: parent.width -Globals.Controls.spacing *2

							IconImage {
								implicitSize: 32
								source: Quickshell.iconPath(delegate.modelData.icon, false)
							}

							ColumnLayout {
								spacing: 0

								Text {
									text: delegate.modelData.name
									color: Globals.Colours.text
									font.pointSize: 10
								}

								Text {
									Layout.fillWidth: true
									text: delegate.modelData.comment
									color: Globals.Colours.light
									elide: Text.ElideRight
									font.pointSize: 6
									font.letterSpacing: 0.6
								}
							}
						}
					}
				}
			}
		}
	}

	IpcHandler {
		target: "launcher"

		function open(): void { loader.active = true; }
	}
}
