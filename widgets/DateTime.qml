/*----------------------------
--- DateTime.qml by andrel ---
----------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
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
				width: grid.width

				Item {
					width: grid.width; height: childrenRect.height;

					Text {
						padding: Globals.Controls.padding
						leftPadding: Globals.Controls.padding *(3 /2)
						text: Qt.formatDate(root.clock.date, "MMMM")
						color: Globals.Colours.text
						font.pointSize: 10
						font.weight: 600
						font.capitalization: Font.AllUppercase
					}
				}

				Row {
					leftPadding: Globals.Controls.padding
					rightPadding: Globals.Controls.padding

					Repeater { id: weekdays
						model: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
						delegate: Text {
							required property var modelData
							required property int index

							width: (grid.width -grid.padding *2) /7
							text: modelData
							horizontalAlignment: Text.AlignHCenter
							color: Globals.Colours.text
							// opacity: 1.0 /weekdays.count *(index +1)
							font.pointSize: 10
							font.weight: 600
						}
					}
				}

				Grid { id: grid
					readonly property int year: root.clock.date.getFullYear()
					readonly property int month: root.clock.date.getMonth()
					readonly property int day: root.clock.date.getDate()

					readonly property int daysInPrevMonth: new Date(year, month -1, 0).getDate()
					readonly property int monthOffset: new Date(year, month, 1).getDay()
					readonly property int daysInMonth: new Date(year, month +1, 0).getDate()

					padding: Globals.Controls.padding
					topPadding: Globals.Controls.spacing
					columns: 7
					columnSpacing: Globals.Controls.spacing
					rowSpacing: 0
					horizontalItemAlignment: Grid.AlignHCenter

					Repeater { id: repeater
						model: {
							const d = grid.monthOffset +grid.daysInMonth;

							return d +(7 -d %7);
						}
						delegate: Text { id: delegate
							required property int index

							readonly property int month: {
								if (delegate.index < grid.monthOffset) return DateTime.Month.Prev;
								else if (delegate.index < (grid.daysInMonth +grid.monthOffset)) return DateTime.Month.Current;
								else return DateTime.Month.Next;
							}
							readonly property int date: {
								const d = delegate.index -grid.monthOffset +1;

								switch (delegate.month) {
									case DateTime.Month.Prev: return grid.daysInPrevMonth +d;
									case DateTime.Month.Current: return d;
									case DateTime.Month.Next: return delegate.index -(grid.daysInMonth +grid.monthOffset) +1;
								}
							}
							readonly property bool isToday: {
								const d = delegate.index -grid.monthOffset +1;

								return grid.day === d;
							}

							padding: Globals.Controls.padding /2
							text: delegate.date
							horizontalAlignment: Text.AlignHCenter
							font.pointSize: 8
							color: {
								if (delegate.isToday) return Globals.Colours.text;

								switch (delegate.month) {
									case DateTime.Month.Prev:
									case DateTime.Month.Next: return Qt.alpha(Globals.Colours.light, 0.4);
									case DateTime.Month.Current: return Qt.alpha(Globals.Colours.text_inactive, 0.6);
								}
							}
							opacity: {
								const t = repeater.count -(grid.daysInMonth +grid.monthOffset);
								const d = delegate.index -(grid.daysInMonth +grid.monthOffset);

								switch (delegate.month) {
									case DateTime.Month.Prev: return 1.0 /grid.monthOffset *(delegate.index +1);
									case DateTime.Month.Current: return 1.0;
									case DateTime.Month.Next: return 1.0 /t *(t -d);
								}
							}
						}
					}
				}
			}
		}
	}
}
