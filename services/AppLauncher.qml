pragma Singleton

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
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
			anchors.top: true
			margins.top: screen.height *(1 /3) -layout.header.height /2
			exclusiveZone: 0
			color: "transparent"
			implicitWidth: layout.width
			implicitHeight: layout.height

			Style.PageLayout { id: layout
				opacity: 0.4
				header: Item {
					// width: parent.width
					height: 32
				}
				body: Ctrl.List {
					model: DesktopEntries
					delegate: RowLayout {
						required property var modelData

						width: parent.width

						Image {
							Layout.preferredWidth: 32
							Layout.preferredHeight: 32

							Rectangle { anchors.fill: parent; }
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
