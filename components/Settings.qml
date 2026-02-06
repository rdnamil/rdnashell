/*----------------------------
--- Settings.qml by andrel ---
----------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.controls as Ctrl
import "../globals.js" as Globals

Singleton { id: root
	readonly property list<var> settings: fileview.adapter.settings

	property int currentIndex: 0

	function init() {}

	FileView { id: fileview
		path: Qt.resolvedUrl("./settings.json")

		JsonAdapter {
			property list<var> settings
		}
	}

	FloatingWindow { id: window
		visible: true
		minimumSize: Qt.size(756, 440)
		onClosed: fileview.writeAdapter();

		Rectangle { anchors.fill: parent; color: Globals.Colours.base; }

		Grid { id: move
			anchors {
				right: parent.right; rightMargin: Globals.Controls.spacing;
				bottom: parent.bottom; bottomMargin: Globals.Controls.spacing;
			}
			spacing: Globals.Controls.spacing /2
			rows: 3; columns: 3;

			Repeater {
				model: 3 *3
				delegate: Rectangle {
					required property int index

					opacity: switch (index) {
						case 2:
						case 4:
						case 5:
						case 6:
						case 7:
						case 8:
							return 1.0;
						default:
							return 0.0;
					}
					width: 3; height: width; radius: height /2;
					color: Globals.Colours.mid
				}
			}
		}

		MouseArea {
			anchors.fill: move
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
					padding: Globals.Controls.padding /2
					text: `Settings -> ${list.model[root.currentIndex]?.name || ''}`
					color: Globals.Colours.text
					font.pointSize: 10
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
						Layout.preferredWidth: 240
						Layout.fillHeight: true
						Layout.margins: Globals.Controls.padding -list.padding
						Layout.leftMargin: 0
						Layout.rightMargin: 0
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
								spacing: Globals.Controls.spacing

								IconImage {
									anchors.verticalCenter: parent.verticalCenter
									implicitSize: 24
									source: Quickshell.iconPath(delegate.modelData.icon)
								}

								Text {
									padding: Globals.Controls.spacing
									text: delegate.modelData.name
									color: Globals.Colours.text
									font.pointSize: 10
									font.weight: 600
								}
							}
						}
					}

					ScrollView { id: scrollview
						Layout.margins: Globals.Controls.padding
						Layout.leftMargin: Globals.Controls.padding -list.padding
						Layout.fillWidth: true
						Layout.fillHeight: true
						ScrollBar.vertical: ScrollBar { id: scrollBarV
							x: scrollview.width -width /2 +Globals.Controls.padding /2
							height: scrollview.availableHeight
							contentItem: Rectangle {
								implicitWidth: scrollBarV.active? 6 : 4
								radius: width /2
								color: scrollBarV.active? Globals.Colours.text : Globals.Colours.mid
								opacity: (scrollBarV.active && scrollBarV.size < 1.0) ? 0.75 : 0

								Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
								Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
								Behavior on color { ColorAnimation { duration: 250; }}
							}
						}
						ScrollBar.horizontal: ScrollBar { id: scrollBarH
							y: scrollview.height -height /2 +Globals.Controls.padding /2
							width: scrollview.availableWidth
							contentItem: Rectangle {
								implicitHeight: scrollBarH.active? 6 : 4
								radius: height /2
								color: scrollBarH.active? Globals.Colours.text : Globals.Colours.mid
								opacity: (scrollBarH.active && scrollBarH.size < 1.0) ? 0.75 : 0

								Behavior on implicitHeight { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
								Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
								Behavior on color { ColorAnimation { duration: 250; }}
							}
						}

						Loader {
							readonly property string component: root.settings[root.currentIndex]?.component || ''

							width: scrollview.availableWidth
							height: scrollview.availableHeight
							active: source
							source: fileview.loaded && component? Qt.resolvedUrl(`./settings/${component}.qml`) : ''
						}
					}
				}
			}
		}
	}

	IpcHandler {
		target: "settings"
		function launch(): void { window.visible = true; }
	}
}
