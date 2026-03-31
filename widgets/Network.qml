pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	function getStrengthUrl(strength = 1.0, security = false) {
		const secure = security? '-secure' : '';

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
			const strength = Service.Network.networks.find(n => n.ssid === Service.Network.status.connection)?.strength || 0.0;

			switch (Service.Network.status.type) {
				case "wifi":
					if (
						Service.Network.status.state.includes("connecting") ||
						Service.Network.status.state.includes("deactivating")
					) return Quickshell.iconPath("network-wireless-acquiring");

					switch (Service.Network.status.connectivity) {
						case "none":
							return Quickshell.iconPath("network-wireless-offline");
						case "portal": // behind portal (limited)
						case "limited": // connected but no internet access
							return Quickshell.iconPath(`network-wireless-${Math.round(strength /20) *20}-limited`);
						case "full":
							return root.getStrengthUrl(strength /100);
						default:
							return Quickshell.iconPath("network");
					}

						default: return Quickshell.iconPath("network");
			}
		}
	}

	Ctrl.Popout { id: popout
		onIsOpenChanged: if (isOpen) Service.Network.scan();
		content: Style.PageLayout { id: content
			header: RowLayout {
				width: content.width

				Row {
					Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
					Layout.margins: Globals.Controls.spacing
					clip: false

					Item {
						width: Globals.Controls.iconSize +Globals.Controls.padding
						height: width

						IconImage {
							anchors.verticalCenter: parent.verticalCenter
							width: implicitSize +Globals.Controls.padding
							implicitSize: Globals.Controls.iconSize
							source: root.getStrengthUrl();
						}
					}

					Ctrl.Switch {
						anchors.verticalCenter: parent.verticalCenter
						toggle: Service.Network.status.radio ?? false
						onClicked: Service.Network.toggleRadio();
					}
				}
			}
			body: Ctrl.List { id: list
				onItemClicked: (item, mouse) => {
					item.connected? item.modelData.disconnect() : item.modelData.connect();
				}
				model: [...Service.Network.networks]
					.filter(n => n.ssid)
					.sort((a, b) => {
						const connected = c => c.ssid === Service.Network.status.connection;

						if (connected(a) || connected(b)) return Number(connected(b)) -Number(connected(a));
						else return b.strength -a.strength
					})
				delegate: GridLayout { id: delegate
					required property var modelData
					required property int index

					readonly property bool connected: Service.Network.status.connection === delegate.modelData.ssid

					width: list.availableWidth
					columns: 2
					columnSpacing: Globals.Controls.spacing
					rowSpacing: 0

					IconImage {
						Layout.leftMargin: Globals.Controls.spacing
						Layout.rowSpan: delegate.connected? 2 : 1
						implicitSize: 24
						source: root.getStrengthUrl(delegate.modelData.strength /100, delegate.modelData.security)
						layer.enabled: list.view.currentIndex === delegate.index
						layer.effect: Colorize { hue: Globals.Colours.mid; }

						Text {
							visible: Globals.Settings.debug
							text: delegate.modelData.strength
							color: Globals.Colours.text
							font.pointSize: 10
						}
					}

					Text {
						Layout.alignment: Qt.AlignVCenter
						Layout.topMargin: Globals.Controls.spacing
						Layout.bottomMargin: delegate.connected? 0 : Globals.Controls.spacing
						Layout.fillWidth: true
						text: delegate.modelData.ssid
						color: Globals.Colours.text
						font.pointSize: 10
					}

					Text {
						visible: delegate.connected
						Layout.bottomMargin: Globals.Controls.spacing
						Layout.fillWidth: true
						text: Service.Network.status.state ?? ''
						color: list.view.currentIndex === delegate.index? Globals.Colours.mid : Globals.Colours.light
						font.pointSize: 6
						font.letterSpacing: 0.6
						font.capitalization: Font.Capitalize
					}
				}

				Connections {
					target: Service.Network

					function onComplete() { popout.isOpen = true; }
				}
			}
		}
	}
}
