/*-----------------------------
--- Bluetooth.qml by andrel ---
-----------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Bluetooth
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	onClicked: popout.toggle();
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: {
			if (Bluetooth.defaultAdapter.devices.values.some(d => d.paired)) return Quickshell.iconPath("bluetooth-paired");
			else if (Bluetooth.defaultAdapter.enabled) return Quickshell.iconPath("bluetooth-active");
			else return Quickshell.iconPath("bluetooth-disabled");
		}
	}

	Ctrl.Popout { id: popout
		content: Style.PageLayout { id: content
			header: RowLayout {
				width: content.width

				Row {
					Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
					Layout.margins: Globals.Controls.spacing
					clip: false

					IconImage {
						anchors.verticalCenter: parent.verticalCenter
						width: implicitSize +Globals.Controls.padding
						implicitSize: 16
						source: Quickshell.iconPath("bluetooth-active")
					}

					Ctrl.Switch {
						toggle: Bluetooth.defaultAdapter.enabled
						onClicked: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
					}
				}

				Ctrl.Button {
					Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
					Layout.margins: Globals.Controls.spacing
					enabled: !discoveringTimeout.running
					onClicked: if (enabled) {
						Bluetooth.defaultAdapter.discovering = true;
						discoveringTimeout.restart();
					}
					icon: IconImage {
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("view-refresh")
					}
					tooltip: "scan for devices"
					opacity: enabled? 1.0 : 0.4

					Timer { id: discoveringTimeout
						interval: 5000
						onTriggered: Bluetooth.defaultAdapter.discovering = false;
					}
				}
			}
			body: Ctrl.List { id: list
				model: Bluetooth.defaultAdapter.devices.values.filter(d => d.deviceName)
				delegate: RowLayout { id: delegate
					required property var modelData

					width: list.availableWidth

					IconImage {
						implicitSize: 24
						source: Quickshell.iconPath(delegate.modelData.icon, "blueman-device")
					}

					Text {
						Layout.fillWidth: true
						text: delegate.modelData.deviceName
						elide: Text.ElideRight
						color: Globals.Colours.text
						font.pointSize: 10
					}
				}
			}
		}
	}
}
