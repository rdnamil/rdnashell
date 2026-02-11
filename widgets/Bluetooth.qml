/*-----------------------------
--- Bluetooth.qml by andrel ---
-----------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Bluetooth
import Quickshell.Wayland
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	acceptedButtons: Qt.LeftButton | Qt.MiddleButton
	onClicked: event => { switch (event.button) {
		case Qt.LeftButton:
			popout.toggle();
			break;
		case Qt.MiddleButton:
			Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
			break;
	}}
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: {
			if (Bluetooth.devices.values.some(d => d.connected)) return Quickshell.iconPath("bluetooth-paired");
			else if (Bluetooth.defaultAdapter?.enabled || false) return Quickshell.iconPath("bluetooth-active");
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
						toggle: Bluetooth.defaultAdapter?.enabled || false
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
				property int lastValidIndex

				mouse.acceptedButtons: Qt.LeftButton | Qt.RightButton
				view.onCountChanged: forget.close();
				onItemClicked: (item, mouse) => {
					const dev = list.model[view.currentIndex];

					switch (mouse.button) {
						case Qt.LeftButton:
							if (dev.pairing) {
								dev.cancelPair();
							} else if (dev.paired) {
								switch (dev.state) {
									case BluetoothDeviceState.Connected:
										dev.disconnect();
										break;
									case BluetoothDeviceState.Disconnected:
										dev.connect();
										break;
									default:
										break;
								}
							} else dev.pair();
							break;
						case Qt.RightButton:
							forget.x = mouse.x -Globals.Controls.radius *2 *0.1464;
							forget.y = mouse.y -Globals.Controls.radius *2 *0.1464;
							forget.menuAnchor = item;
							forget.open();
							break;
					}
				}
				model: Bluetooth.devices.values.filter(d => d.deviceName) || []
				delegate: RowLayout { id: delegate
					required property var modelData
					required property int index

					width: list.availableWidth

					IconImage {
						Layout.margins: Globals.Controls.spacing
						implicitSize: 24
						source: switch (delegate.modelData.icon) {
							case "input-gaming":
								return Quickshell.iconPath("input-gamepad");
							default:
								return Quickshell.iconPath(delegate.modelData.icon, "blueman-device");
						}
					}

					ColumnLayout {
						spacing: 0

						Text {
							Layout.fillWidth: true
							text: delegate.modelData.deviceName
							elide: Text.ElideRight
							color: Globals.Colours.text
							font.pointSize: 10
						}

						Text {
							Layout.fillWidth: true
							text: {
								if (delegate.modelData.pairing) return "Pairing";
								else if (delegate.modelData.state !== BluetoothDeviceState.Disconnected)
									return BluetoothDeviceState.toString(delegate.modelData.state);
								else return delegate.modelData.address;
							}
							elide: Text.ElideRight
							color: delegate.index === list.view.currentIndex? Globals.Colours.mid : Globals.Colours.light
							font.pointSize: 6
							font.letterSpacing: 0.6
						}
					}

					Connections {
						target: delegate.modelData

						function onConnectedChanged() {
							if (delegate.modelData.paired) {
								delegate.modelData.trusted = true;
							}
						}
					}
				}

				Ctrl.PopupMenu { id: forget
					property Item menuAnchor: null

					width: 72
					model: [
						{ "icon": 'dialog-question', "text": 'forget' },
						{ "icon": 'action-unavailable', "text": 'cancel' },
					]
					onSelected: index => {
						if (index === 0) menuAnchor.modelData.forget();
						menuAnchor = null;
					}
				}
			}
		}
	}
}
