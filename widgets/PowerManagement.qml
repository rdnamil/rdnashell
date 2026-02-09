/*-----------------------------------
--- PowerManagement.qml by andrel ---
-----------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	onClicked: popout.toggle();
	icon: Item { id: icon
		width: childrenRect.width
		height: Globals.Controls.iconSize +1

		Ctrl.Battery { id: battery
			visible: UPower.displayDevice.isLaptopBattery
			percentage: UPower.displayDevice.percentage
			isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged
		}

		Item { id: performanceProfile
			visible: !battery.visible && PowerProfiles.hasPerformanceProfile
			anchors.verticalCenter: parent.verticalCenter
			width: visible? Globals.Controls.iconSize : 0
			height: width

			IconImage {
				anchors.centerIn: parent
				implicitSize: 32
				source: switch (PowerProfiles.profile) {
					case PowerProfile.Performance:
						return Quickshell.iconPath("battery-profile-performance");
					case PowerProfile.Balanced:
						return Quickshell.iconPath("battery-profile-balanced");
					case PowerProfile.PowerSaver:
						return Quickshell.iconPath("battery-profile-powersave");
				}
				transform: Scale {
					origin { x: 16; y: 16; }
					xScale: icon.width /32
					yScale: xScale
				}
			}
		}

		IconImage {
			visible: !battery.visible && !performanceProfile.visible
			implicitSize: visible? Globals.Controls.iconSize : 0
			source: Quickshell.iconPath("battery");
		}
	}

	Ctrl.Popout { id: popout
		content: Style.PageLayout { id: content
			header: RowLayout {
				spacing: 0
				width: content.width

				IconImage {
					Layout.margins: Globals.Controls.spacing *2
					Layout.rightMargin: Globals.Controls.spacing
					implicitSize: Globals.Controls.iconSize
					source: Quickshell.iconPath("battery-profile-balanced");
				}

				Ctrl.Dropdown { id: drop
					readonly property list<var> profiles: [PowerProfile.Performance, PowerProfile.Balanced, PowerProfile.PowerSaver]

					Layout.margins: Globals.Controls.spacing
					Layout.fillWidth: true
					tooltip: "Power profile"
					currentIndex: drop.profiles.findIndex(p => p === PowerProfiles.profile)
					onSelected: index => { if (index !== -1) PowerProfiles.profile = drop.profiles[index]; }
					model: [...drop.profiles].map(p => PowerProfile.toString(p))
				}
			}
			body: Ctrl.List { id: list
				view.highlight: Item {}
				view.spacing: Globals.Controls.spacing
				view.clip: false
				model: UPower.devices.values
					.filter(d => d !== UPower.displayDevice) // don't show display device
					.filter(d => !d.isLaptopBattery) // don't display laptop battery
					.filter(d => d.model) // remove devices with no model name
				delegate: Item { id: delegate
					required property var modelData
					required property int index

					width: list.availableWidth
					height: delegateLayout.height

					Rectangle {
						anchors.centerIn: parent
						width: parent.width +Globals.Controls.spacing
						height: parent.height +Globals.Controls.spacing
						radius: Globals.Controls.radius *(3 /4)
						color: Globals.Colours.light
						opacity: delegate.index %2 === 1? 0.25 : 0.0
					}

					RowLayout { id: delegateLayout
						width: parent.width

						Item {
							Layout.preferredWidth: childrenRect.width -smBattery.anchors.rightMargin
							Layout.preferredHeight: childrenRect.width -smBattery.anchors.bottomMargin

							IconImage { id: deviceIcon
								implicitSize: 24
								source: switch (delegate.modelData.type) {
									case UPowerDeviceType.Computer:
										return Quickshell.iconPath("laptop");
									case UPowerDeviceType.Mouse:
										return Quickshell.iconPath("input-mouse");
									case UPowerDeviceType.Keyboard:
										return Quickshell.iconPath("input-keyboard");
									case UPowerDeviceType.GamingInput:
										return Quickshell.iconPath("input-gamepad");
									default:
										Quickshell.iconPath("device_pci");
								}
								// onSourceChanged: console.log(UPowerDeviceType.toString(delegate.modelData.type))
								layer.enabled: true
								layer.effect: OpacityMask { maskSource: Item {
									width: deviceIcon.width; height: deviceIcon.height

									Rectangle {
										anchors {
											right: parent.right; rightMargin: smBattery.anchors.rightMargin -2;
											bottom: parent.bottom; bottomMargin: smBattery.anchors.bottomMargin -2;
										}
										width: smBattery.width +4
										height: smBattery.height +3
										radius: 4

										Rectangle { anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.top; } width: 8; height: 1; }
									}
								} invert: true; }
							}

							Ctrl.Battery { id: smBattery
								// visible: false
								anchors {
									right: deviceIcon.right
									rightMargin: -4
									bottom: deviceIcon.bottom
									// bottomMargin: -2
								}
								width: 10
								height: 14
								percentage: delegate.modelData.percentage
								isCharging: delegate.modelData.state === UPowerDeviceState.Charging
							}
						}

						Text {
							Layout.fillWidth: true
							text: delegate.modelData.model
							color: Globals.Colours.text
							font.pointSize: 8
							font.weight: 500
							font.letterSpacing: 0.5
						}
					}
				}
			}
		}
	}
}
