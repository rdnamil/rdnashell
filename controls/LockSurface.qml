/*-------------------------------
--- LockSurface.qml by andrel ---
-------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.controls as Ctrl
import "../globals.js" as Globals

Item { id: root
	required property Ctrl.LockContext context

	readonly property SystemClock clock: SystemClock { id: clock; }

	property url wallpaper: ''

	anchors.fill: parent

	Rectangle { anchors.fill: parent; color: Globals.Colours.mid; }

	Image {
		anchors.fill: parent
		source: root.wallpaper
	}

	ColumnLayout {
		x: root.width /2 -width /2
		y: root.height /2 -height /2 -passwd.y /2

		Text {
			Layout.alignment: Qt.AlignHCenter
			text: Qt.formatTime(root.clock.date, "hh:mm")
			color: Globals.Colours.text
			font.pointSize: 92
			layer.enabled: true
			layer.effect: DropShadow { samples: 64; color: Qt.alpha("black", 0.4); }
		}

		Item { id: passwd
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 360
			Layout.preferredHeight: textLayout.height

			RectangularShadow {
				anchors.fill: parent
				radius: Globals.Controls.radius *(3 /4)
				blur: 30
				opacity: 0.4
			}

			Rectangle {
				anchors.fill: parent
				radius: Globals.Controls.radius *(3 /4)
				color: Globals.Colours.dark
				border { width: 1; color: root.context.showFailure? Globals.Colours.danger : "transparent"; }
			}

			RowLayout { id: textLayout
				width: parent.width

				TextInput { id: textInput
					horizontalAlignment: Text.AlignHCenter
					Layout.margins: Globals.Controls.padding /2
					Layout.fillWidth: true
					focus: true
					clip: true
					enabled: !root.context.unlockInProgress
					cursorDelegate: Item {}
					echoMode: TextInput.Password
					inputMethodHints: Qt.ImhSensitiveData
					color: enabled? Globals.Colours.text : Globals.Colours.light
					font.pointSize: 10
					onTextChanged: if (root.context.showFailure) root.context.showFailure = false;
					onAccepted: if (!root.context.unlockInProgress) root.context.tryUnlock(this.text);

					Text {
						visible: root.context.showFailure
						anchors.centerIn: parent
						text: "Incorrect password"
						color: Globals.Colours.text
						font.pointSize: 10
						font.italic: true
					}

					Connections {
						target: root.context

						function onFailed() { textInput.clear(); }
					}
				}
			}
		}
	}

	Rectangle {
		visible: Globals.Settings.debug
		anchors.centerIn: parent
		width: childrenRect.width
		height: childrenRect.height

		Text {
			text: "unlock me"
			MouseArea {
				anchors.fill: parent
				onClicked: root.context.unlocked();
			}
		}
	}
}
