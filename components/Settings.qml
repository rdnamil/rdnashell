/*----------------------------
--- Settings.qml by andrel ---
----------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Singleton { id: root
	readonly property list<var> settings: jsonAdapter.settings

	property int currentIndex: 0

	function init() {}

	FileView { id: fileview
		path: Qt.resolvedUrl("./settings.json")

		JsonAdapter { id: jsonAdapter
			property list<var> settings
		}
	}

	FloatingWindow { id: window
		visible: true
		onClosed: fileview.writeAdapter();

		Rectangle {
			anchors.fill: parent
			color: Globals.Colours.base
		}

		MouseArea {
			anchors { right: parent.right; bottom: parent.bottom; }
			width: 10; height: width;
			cursorShape: Qt.SizeFDiagCursor
			onPressed: window.startSystemResize(Edges.Right | Edges.Bottom)
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
					spacing: 0
					anchors.fill: parent

					Ctrl.List { id: list
						Layout.preferredWidth: 210
						Layout.fillHeight: true
						onItemClicked: root.currentIndex = view.currentIndex;
						view.currentIndex: -1
						model: root.settings
						delegate: Item { id: delegate
							required property var modelData
							required property int index

							width: list.availableWidth
							height: childrenRect.height

							Rectangle {
								visible: root.currentIndex == delegate.index
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

					Loader {
						Layout.fillWidth: true
						Layout.fillHeight: true

						active: source
						source: fileview.loaded? Qt.resolvedUrl(`./settings/${root.settings[root.currentIndex].component}.qml`) : ''
					}
				}
			}
		}
	}
}
