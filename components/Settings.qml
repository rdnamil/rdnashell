/*----------------------------
--- Settings.qml by andrel ---
----------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Singleton { id: root
	readonly property list<var> settings: [
		{
			"name": "Wallpaper",
			"icon": "livewallpaper",
			"component": 'url'
		}
	]

	property int currentIndex: 0

	function init() {}

	FloatingWindow { id: window
		visible: true

		Rectangle {
			anchors.fill: parent
			color: Globals.Colours.base
		}

		ColumnLayout {
			anchors.fill: parent
			spacing: 0

			Rectangle { id: header
				Layout.fillWidth: true
				Layout.preferredHeight: childrenRect.height
				color: Globals.Colours.dark

				Text {
					anchors.centerIn: parent
					padding: Globals.Controls.padding
					text: "Settings"
					color: Globals.Colours.text
					font.pointSize: 12
					font.weight: 600
				}

				MouseArea {
					anchors.fill: parent
					onPressed: window.startSystemMove();
				}
			}

			Item {
				Layout.fillWidth: true
				Layout.fillHeight: true

				RowLayout {
					anchors.fill: parent

					Ctrl.List { id: list
						Layout.preferredWidth: 210
						Layout.fillHeight: true
						model: root.settings
						delegate: Item { id: delegate
							required property var modelData
							required property int index

							width: list.availableWidth
							height: childrenRect.height

							Rectangle {
								anchors.fill: parent
								radius: Globals.Controls.radius *(3 /4)
								color: Globals.Colours.accent
								opacity: 0.8
							}

							Row {
								padding: Globals.Controls.spacing /2

								IconImage {
									anchors.verticalCenter: parent.verticalCenter
									implicitSize: 24
									source: Quickshell.iconPath(delegate.modelData.icon)
								}

								Text {
									padding: Globals.Controls.spacing
									text: delegate.modelData.name
									color: Globals.Colours.text
									font.pointSize: 12
									font.weight: 500
								}
							}
						}
					}
				}
			}
		}
	}
}
