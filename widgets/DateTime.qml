/*----------------------------
--- DateTime.qml by andrel ---
----------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	readonly property SystemClock clock: SystemClock { id: clock; precision: SystemClock.Seconds; }

	property bool stack

	onClicked: popout.toggle();
	icon: GridLayout {
		rowSpacing: 0
		columnSpacing: Globals.Controls.spacing
		columns: root.stack? 1 : 3
		width: {
			const w = Math.round(implicitWidth);
			return w +w %2;
		}

		Text {
			Layout.alignment: root.stack? Qt.AlignHCenter : 0
			text: Qt.formatDate(root.clock.date, "ddd d")
			color: Globals.Colours.light
			font.pointSize: 10
			font.weight: 500
		}
		Rectangle {
			visible: !root.stack
			Layout.preferredWidth: 4; Layout.preferredHeight: width; radius: height /2;
			color: Globals.Colours.text
		}
		Text {
			Layout.alignment: root.stack? Qt.AlignHCenter : 0
			text: Qt.formatTime(root.clock.date, "h:mm")
			color: Globals.Colours.text
			font.pointSize: 10
			font.weight: 600
		}
	}

	Ctrl.Popout { id: popout
		content: Style.PageLayout {
			body: Column { id: calendar
				spacing: 0
				width: 340

				Text {
					padding: Globals.Controls.padding
					text: Qt.formatDate(root.clock.date, "MMMM")
					color: Globals.Colours.text
					font.pointSize: 10
					font.weight: 600
					font.capitalization: Font.AllUppercase
				}

				RowLayout {
					spacing: 0

					Repeater {
						model: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
						delegate: Text {
							required property var modelData

							Layout.margins: Globals.Controls.spacing
							Layout.preferredWidth: calendar.width /7
							text: modelData
							horizontalAlignment: Text.AlignHCenter
							color: Globals.Colours.text
							font.pointSize: 10
							font.weight: 600
						}
					}
				}

				GridLayout {
					width: parent.width
					columns: 7
					columnSpacing: 0
					rowSpacing: 0

					Repeater {
						model: 31
						delegate: Item { id: delegate
							required property int index

							Layout.margins: Globals.Controls.spacing
							Layout.preferredWidth: calendar.width /7
							Layout.preferredHeight: childrenRect.height

							Text {
								anchors.centerIn: parent
								padding: Globals.Controls.spacing
								text: delegate.index +1
								color: Globals.Colours.text
								font.pointSize: 8

								Rectangle {
									anchors.centerIn: parent
									width: height; height: parent.height;
									radius: 4
									z: -999
									color: Globals.Colours.light
									opacity: 0.0
								}
							}
						}
					}
				}

				Item { width: -1; height: Globals.Controls.padding; }
			}
			footer: Item {}
		}
	}
}
