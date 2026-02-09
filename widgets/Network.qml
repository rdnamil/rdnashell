/*---------------------------
--- Network.qml by andrel ---
---------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Networking
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	function getSignalUrl(strength = 1.0, security = WifiSecurityType.Open) {
		const secure = security === WifiSecurityType.Open? '' : '-secure';

		if (strength < (1 /5)) return Quickshell.iconPath(`network-wireless${secure}-signal-none`);
		if (strength < (2 /5)) return Quickshell.iconPath(`network-wireless${secure}-signal-low`);
		if (strength < (3 /5)) return Quickshell.iconPath(`network-wireless${secure}-signal-ok`);
		if (strength < (4 /5)) return Quickshell.iconPath(`network-wireless${secure}-signal-good`);
		else return Quickshell.iconPath(`network-wireless${secure}-signal-excellent`);
	}

	onClicked: popout.toggle();
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: {
			const n = Networking.devices.values
				.find(d => d.type === DeviceType.Wifi)?.networks.values
				.find(n => n.connected);
			return root.getSignalUrl(n?.signalStrength || 0);
		}
	}

	Ctrl.Popout { id: popout
		window.onVisibleChanged: {
			if (window.visible) Networking.devices.values
				.find(d => d.type === DeviceType.Wifi)
				.scannerEnabled = true;
			else Networking.devices.values
				.find(d => d.type === DeviceType.Wifi)
				.scannerEnabled = false;
		}
		content: Style.PageLayout { id: content
			header: RowLayout {
				width: content.width

				Row {
					Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
					Layout.margins: Globals.Controls.spacing *2
					clip: false

					IconImage {
						anchors.verticalCenter: parent.verticalCenter
						width: implicitSize +Globals.Controls.padding
						implicitSize: 16
						source: Quickshell.iconPath("network-wireless")
					}

					Ctrl.Switch {
						toggle: Networking.wifiEnabled
						onClicked: Networking.wifiEnabled = !Networking.wifiEnabled;
					}
				}
			}
			body: Ctrl.List { id: list
				model: [...Networking.devices.values.slice()]
					.find(d => d.type === DeviceType.Wifi)?.networks.values || []
				delegate: RowLayout { id: delegate
					required property var modelData
					required property int index

					width: list.availableWidth
					spacing: 0

					IconImage {
						readonly property Component colourMid: Colorize { hue: Globals.Colours.mid; }

						Layout.margins: Globals.Controls.spacing
						implicitSize: 24
						source: root.getSignalUrl(delegate.modelData.signalStrength, delegate.modelData.security)
						layer.enabled: true
						layer.effect: delegate.index === list.view.currentIndex? colourMid : null
					}

					ColumnLayout {
						Layout.margins: Globals.Controls.spacing
						spacing: 0

						Text {
							Layout.fillWidth: true
							text: delegate.modelData.name
							elide: Text.ElideRight
							color: Globals.Colours.text
							font.pointSize: 10
						}

						Text {
							visible: delegate.modelData.state !== NetworkState.Disconnected
							Layout.fillWidth: true
							text: NetworkState.toString(delegate.modelData.state)
							elide: Text.ElideRight
							color: delegate.index === list.view.currentIndex? Globals.Colours.mid : Globals.Colours.light
							font.pointSize: 6
							font.letterSpacing: 0.6
						}
					}
				}
			}
		}
	}
}
