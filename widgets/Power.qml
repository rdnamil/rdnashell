pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.controls as Ctrl
import "../globals.js" as Globals

Ctrl.Widget { id: root
	onClicked: loader.active = !loader.active;
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: Quickshell.iconPath("system-shutdown-symbolic")
	}

	Loader { id: loader
		active: false
		sourceComponent: PanelWindow { id: window
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			exclusiveZone: -1
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

			ColorAnimation on color { from: "transparent"; to: Qt.alpha("black", 0.6); duration: 500; easing.type: Easing.OutCirc; }

			ParallelAnimation { id: fadeOutAnim
				onFinished: loader.active = false;

				ColorAnimation {
					target: window; property: "color";
					to: "transparent"
					duration: 500; easing.type: Easing.OutCirc;
				}

				NumberAnimation {
					target: options; property: "opacity";
					to: 0.0
					duration: 500; easing.type: Easing.OutCirc;
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: fadeOutAnim.start();
			}

			RectangularShadow {
				anchors.fill: options
				radius: options.radius
				blur: 60
				opacity: 0.2 *options.opacity
			}

			Rectangle { id: options
				anchors.centerIn: parent
				width: 480
				height: layout.height
				radius: Globals.Controls.radius
				color: Globals.Colours.base
				border { width: 1; color: Qt.alpha(Globals.Colours.mid, 0.6); }
 				focus: true
				Keys.onEscapePressed: fadeOutAnim.start();

				NumberAnimation on opacity { from: 0.0; to: 0.975; duration: 500; easing.type: Easing.OutCirc; }

				MouseArea { anchors.fill: parent; } // to prevent clicking on background unloading

				Column { id: layout
					padding: Globals.Controls.padding
					spacing: Globals.Controls.padding *2

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						text: "Power Options"
						color: Globals.Colours.text
						font.pointSize: 12
						font.weight: 600
						font.letterSpacing: 0.6
					}

					RowLayout {
						width: options.width -parent.padding *2
						spacing: Globals.Controls.padding
						uniformCellSizes: true

						Ctrl.Button {
							Layout.fillWidth: true
							onClicked: fadeOutAnim.start();
							icon: Text {
								text: "Cancel"
								color: Globals.Colours.text
								font.pointSize: 10
								font.weight: 600
								font.letterSpacing: 0.4
							}
							background.color: Globals.Colours.text
							cursorShape: Qt.PointingHandCursor

							Rectangle {
								anchors.fill: parent
								z: -2
								radius: parent.background.radius
								color: Globals.Colours.light
								opacity: 0.2
							}
						}

						Ctrl.Button {
							Layout.fillWidth: true
							onClicked: Quickshell.execDetached(['niri', 'msg', 'action', 'quit']);
							icon: Text {
								text: "Logout"
								color: Globals.Colours.text
								font.pointSize: 10
								font.weight: 600
								font.letterSpacing: 0.4
							}
							background.color: Globals.Colours.text
							cursorShape: Qt.PointingHandCursor

							Rectangle {
								anchors.fill: parent
								z: -2
								radius: parent.background.radius
								color: Globals.Colours.light
								opacity: 0.2
							}
						}

						Ctrl.Button {
							Layout.fillWidth: true
							onClicked: Quickshell.execDetached(['reboot']);
							icon: Text {
								text: "Restart"
								color: Globals.Colours.text
								font.pointSize: 10
								font.weight: 600
								font.letterSpacing: 0.4
							}
							background.color: Globals.Colours.text
							cursorShape: Qt.PointingHandCursor

							Rectangle {
								anchors.fill: parent
								z: -2
								radius: parent.background.radius
								color: Globals.Colours.light
								opacity: 0.2
							}
						}

						Ctrl.Button {
							Layout.fillWidth: true
							onClicked: Quickshell.execDetached(['poweroff']);
							icon: Text {
								text: "Shut Down"
								color: Globals.Colours.text
								font.pointSize: 10
								font.weight: 600
								font.letterSpacing: 0.4
							}
							cursorShape: Qt.PointingHandCursor
							background.color: Qt.darker(Globals.Colours.danger, 0.4)

							Rectangle {
								anchors.fill: parent
								z: -2
								radius: parent.background.radius
								color: Qt.darker(Globals.Colours.danger, 1.6)
							}
						}
					}
				}
			}
		}
	}
}
