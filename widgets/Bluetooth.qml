import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	acceptedButtons: Qt.LeftButton | Qt.MiddleButton
	onClicked: (mouse) => { switch (mouse.button) {
		case Qt.LeftButton: popout.toggle(); break;
		case Qt.MiddleButton: Service.Bluetooth.toggleAdapter(); break;
	}}
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: if (Service.Bluetooth.isPaired) return Quickshell.iconPath("bluetooth-paired");
		else if (Service.Bluetooth.isPowered) return Quickshell.iconPath("bluetooth-active");
		else return Quickshell.iconPath("bluetooth-disabled");
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
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("bluetooth-active")
					}

					Ctrl.Switch {
						toggle: Service.Bluetooth.isPowered
						onClicked: Service.Bluetooth.toggleAdapter();
					}
				}

				Ctrl.Button {
					Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
					Layout.margins: Globals.Controls.spacing
					enabled: !Service.Bluetooth.isScanning
					onClicked: if (enabled) Service.Bluetooth.scan();
					icon: IconImage {
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("view-refresh")
					}
					opacity: enabled? 1.0 : 0.4
				}
			}
			body: Ctrl.List { id: list
				onItemClicked: (item, mouse) => {
					if (item.modelData.connected) {
						item.modelData.disconnect();
						item.status = 1;
					} else if (!item.modelData.paired) {
						item.modelData.connect();
						item.status = 2;
					}
				}
				model: [...Service.Bluetooth.devices]
				.filter(d => d.name)
				.sort((a, b) => {
					const rank = d => d.connected? 0 : d.paired? 1 : 2;
					return rank(a) -rank(b);
				})
				delegate: GridLayout { id: delegate
					required property var modelData
					required property int index

					property int status: delegate.modelData.connected? 4 : 0

					width: list.availableWidth
					columns: 2
					columnSpacing: Globals.Controls.spacing
					rowSpacing: 0

					IconImage {
						Layout.leftMargin: Globals.Controls.spacing
						Layout.rowSpan: 2
						implicitSize: 24
						source: switch (delegate.modelData.icon) {
							case "input-gaming":
								return Quickshell.iconPath("input-gamepad");
							default:
								return Quickshell.iconPath(delegate.modelData.icon, "blueman-device");
						}
					}

					Text {
						Layout.topMargin: Globals.Controls.spacing
						Layout.fillWidth: true
						text: delegate.modelData.name
						color: Globals.Colours.text
						font.pointSize: 10
					}

					Text {
						Layout.bottomMargin: Globals.Controls.spacing
						Layout.fillWidth: true
						text: switch (delegate.status) {
							case 0: return delegate.modelData.address;
							case 1: return "Disconnecting";
							case 2: return "Connecting";
							case 4: return "Connected";
						}
						color: delegate.index === list.view.currentIndex? Globals.Colours.mid : Globals.Colours.light
						font.pointSize: 6
						font.letterSpacing: 0.6
					}
				}
			}
		}
	}
}
