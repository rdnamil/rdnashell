/*-------------------------------
--- LockSurface.qml by andrel ---
-------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Item { id: root
	required property Ctrl.LockContext context

	readonly property SystemClock clock: SystemClock { id: clock; }

	property ShellScreen screen: QsWindow.window?.screen || null
	property int state: LockSurface.State.Cover

	enum State {
		Cover,
		SignIn
	}

	anchors.fill: parent
	focus: true
	Keys.onPressed: event => { if (event.key !== Qt.Key_Escape) root.state = LockSurface.State.SignIn; }
	onStateChanged: switch (root.state) {
		case LockSurface.State.Cover:
			root.focus = true;
			textInput.clear();
			inactivity.stop();
			coverAnim.start();
			break;
		case LockSurface.State.SignIn:
			textInput.focus = true;
			inactivity.start();
			signInAnim.start();
			break;
	}

	Rectangle { anchors.fill: parent; color: Globals.Colours.mid; }

	Image {
		anchors.fill: parent
		source: Service.Swww.wallpapers.find(w => w.display === root.screen?.name)?.path || ''
		layer.enabled: true
		layer.effect: GaussianBlur {
			samples: switch (root.state) {
				case LockSurface.State.Cover:
					return 0;
				case LockSurface.State.SignIn:
					return 64;
			}

			Behavior on samples { NumberAnimation { duration: 500; easing.type: Easing.Linear; }}
		}
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onClicked: if (root.state !== LockSurface.State.SignIn) root.state = LockSurface.State.SignIn;
		onPositionChanged: if (inactivity.running) inactivity.restart();
	}

	ParallelAnimation { id: signInAnim
		NumberAnimation {
			target: cover; property: "y";
			from: cover.yOffset; to: 0;
			duration: 500; easing.type: Easing.OutCirc;
		}
		NumberAnimation {
			target: cover; property: "opacity";
			from: 1.0; to: 0.0;
			duration: 500; easing.type: Easing.OutCirc;
		}
		NumberAnimation {
			target: scale; properties: "xScale, yScale";
			from: 0.5; to: 1.0;
			duration: 500; easing.type: Easing.OutCirc;
		}
		NumberAnimation {
			target: signIn; property: "opacity";
			from: 0.0; to: 1.0;
			duration: 500; easing.type: Easing.OutCirc;
		}
	}

	ParallelAnimation { id: coverAnim
		NumberAnimation {
			target: cover; property: "y";
			to: cover.yOffset; from: 0;
			duration: 500; easing.type: Easing.OutCirc;
		}
		NumberAnimation {
			target: cover; property: "opacity";
			to: 1.0; from: 0.0;
			duration: 500; easing.type: Easing.InCirc;
		}
		NumberAnimation {
			target: scale; properties: "xScale, yScale";
			to: 0.5; from: 1.0;
			duration: 500; easing.type: Easing.OutCirc;
		}
		NumberAnimation {
			target: signIn; property: "opacity";
			to: 0.0; from: 1.0;
			duration: 500; easing.type: Easing.OutCirc;
		}
	}

	ColumnLayout { id: cover
		readonly property real yOffset: root.height /2 -height /2 -time.y /2

		spacing: 0
		x: root.width /2 -width /2
		y: yOffset

		Text {
			Layout.alignment: Qt.AlignHCenter
			Layout.bottomMargin: -12
			text: Qt.formatDate(root.clock.date, "dddd MMMM, d")
			renderType: Text.NativeRendering
			color: Globals.Colours.text
			font.pointSize: 24
			font.weight: 600
			layer.enabled: true
			layer.effect: DropShadow { samples: 64; color: Qt.alpha("black", 0.4); }
		}

		Text { id: time
			Layout.alignment: Qt.AlignHCenter
			text: Qt.formatTime(root.clock.date, "hh:mm")
			renderType: Text.NativeRendering
			color: Globals.Colours.text
			font.pointSize: 92
			layer.enabled: true
			layer.effect: DropShadow { samples: 64; color: Qt.alpha("black", 0.4); }
		}
	}

	ColumnLayout { id: signIn
		readonly property real yOffset: root.height /2 -height +passwd.height /2

		spacing: Globals.Controls.padding
		x: root.width /2 -width /2
		y: yOffset
		transform: Scale { id: scale; origin { x: signIn.width /2; y: signIn.height /2; }}
		opacity: 0.0

		Image {
			Layout.alignment: Qt.AlignHCenter
			Layout.bottomMargin: -Globals.Controls.padding
			Layout.preferredWidth: 120
			Layout.preferredHeight: width
			source: Quickshell.iconPath("system-users")
			mipmap: true
		}

		Text {
			Layout.alignment: Qt.AlignHCenter
			text: getUserFullName.userFullName
			color: Globals.Colours.text
			font.pointSize: 16
		}

		Item { id: passwd
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 240
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
					focus: false
					clip: true
					enabled: !root.context.unlockInProgress
					cursorDelegate: Item {}
					echoMode: TextInput.Password
					inputMethodHints: Qt.ImhSensitiveData
					color: enabled? Globals.Colours.text : Globals.Colours.light
					selectedTextColor: Globals.Colours.accent
					selectionColor: Qt.darker(Globals.Colours.accent, 1.4)
					font.pointSize: 12
					onTextChanged: if (root.context.showFailure) root.context.showFailure = false;
					onAccepted: if (!root.context.unlockInProgress) root.context.tryUnlock(this.text);
					Keys.onPressed: event => {
						if (event.key === Qt.Key_Escape) root.state = LockSurface.State.Cover;
						else inactivity.restart();
					}

					Text {
						visible: root.context.showFailure
						anchors.centerIn: parent
						text: "Incorrect password"
						color: Globals.Colours.danger
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

	RowLayout {
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom; bottomMargin: Globals.Controls.padding;
		}
		opacity: root.state === LockSurface.State.SignIn? 1.0 : 0.0

		Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCirc; }}

		Ctrl.Button {
			icon: IconImage {
				implicitSize: 32
				source: Quickshell.iconPath("system-log-out")
			}
			onClicked: Quickshell.execDetached(['niri', 'msg', 'action', 'quit', '-s']);
		}

		Ctrl.Button {
			icon: IconImage {
				implicitSize: 32
				source: Quickshell.iconPath("system-reboot")
			}
			onClicked: Quickshell.execDetached(['reboot']);
		}

		Ctrl.Button {
			icon: IconImage {
				implicitSize: 32
				source: Quickshell.iconPath("system-shutdown")
			}
			onClicked: Quickshell.execDetached(['poweroff']);
		}
	}

	Timer { id: inactivity
		interval: 3e5
		onTriggered: root.state = LockSurface.State.Cover;
	}

	Process { id: getUserFullName
		property string userFullName: ''

		running: true
		command: ['sh', '-c', 'getent passwd "$(whoami)" | cut -d: -f5 | cut -d, -f1']
		stdout: StdioCollector { onStreamFinished: getUserFullName.userFullName = text; }
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
