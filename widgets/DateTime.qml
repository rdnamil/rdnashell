/*----------------------------
--- DateTime.qml by andrel ---
----------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	readonly property SystemClock clock: SystemClock { id: clock; precision: SystemClock.Seconds; }

	property bool stack

	enum Month {
		Prev,
		Current,
		Next
	}

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
					x: calendar.width /(7 *3)
					leftPadding: 0
					padding: Globals.Controls.padding
					text: Qt.formatDate(root.clock.date, "MMMM")
					color: Globals.Colours.text
					font.pointSize: 10
					font.weight: 600
					font.capitalization: Font.AllUppercase
				}

				RowLayout {
					spacing: 0

					Repeater { id: weekdays
						model: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
						delegate: Text {
							required property var modelData
							required property int index

							Layout.margins: Globals.Controls.spacing
							Layout.preferredWidth: calendar.width /7
							text: modelData
							horizontalAlignment: Text.AlignHCenter
							color: Globals.Colours.text
							// opacity: 1.0 /weekdays.count *(index +1)
							font.pointSize: 10
							font.weight: 600
						}
					}
				}

				GridLayout { id: grid
					readonly property int year: root.clock.date.getFullYear()
					readonly property int month: root.clock.date.getMonth()
					readonly property int day: root.clock.date.getDate()

					readonly property int daysInPrevMonth: new Date(year, month -1, 0).getDate()
					readonly property int monthOffset: new Date(year, month, 1).getDay()
					readonly property int daysInMonth: new Date(year, month +1, 0).getDate()

					width: parent.width
					columns: 7
					columnSpacing: 0
					rowSpacing: 0

					Repeater { id: repeater
						model: {
							const d = grid.monthOffset +grid.daysInMonth;

							return d +(7 -d %7);
						}
						delegate: Ctrl.Button { id: delegate
							required property int index

							readonly property int month: {
								if (delegate.index < grid.monthOffset) return DateTime.Month.Prev;
								else if (delegate.index < (grid.daysInMonth +grid.monthOffset)) return DateTime.Month.Current;
								else return DateTime.Month.Next;
							}
							readonly property bool isToday: {
								const d = delegate.index -grid.monthOffset +1;

								return grid.day === d;
							}

							Layout.margins: Globals.Controls.spacing
							Layout.preferredWidth: calendar.width /7
							Layout.preferredHeight: icon.height
							enabled: month === DateTime.Month.Current
							background.width: icon.height +Globals.Controls.spacing
							background.height: background.width;
							icon: Text {
								anchors.centerIn: parent
								padding: Globals.Controls.spacing
								text: {
									const d = delegate.index -grid.monthOffset +1;

									switch (delegate.month) {
										case DateTime.Month.Prev: return grid.daysInPrevMonth +d;
										case DateTime.Month.Current: return d;
										case DateTime.Month.Next: return delegate.index -(grid.daysInMonth +grid.monthOffset) +1;
									}
								}
								color: {
									if (delegate.isToday) return Globals.Colours.text;

									switch (delegate.month) {
										case DateTime.Month.Prev:
										case DateTime.Month.Next: return Qt.alpha(Globals.Colours.light, 0.4);
										case DateTime.Month.Current: return Qt.alpha(Globals.Colours.text, 0.6);
									}
								}
								font.pointSize: 8
							}
							effectEnabled: false
							effect: Component { DropShadow {
								samples: 16
								color: delegate.isToday? Qt.alpha("black", 0.2) : "transparent"
							}}
							opacity: {
								const t = repeater.count -(grid.daysInMonth +grid.monthOffset);
								const d = delegate.index -(grid.daysInMonth +grid.monthOffset) +1;

								switch (delegate.month) {
									case DateTime.Month.Prev: return 1.0 /grid.monthOffset *(delegate.index +1);
									case DateTime.Month.Current: return 1.0;
									case DateTime.Month.Next: return 1.0 /t *(t -d);
								}
							}

							ShaderEffectSource {
								visible: delegate.isToday
								anchors.fill: delegate.background
								z: -999
								sourceItem: delegate.background
								opacity: 0.2
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
