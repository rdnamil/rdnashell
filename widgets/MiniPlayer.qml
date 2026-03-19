pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	// format time from total seconds to hours:minutes:seconds
	function formatTime(totalSeconds) {
		var seconds = totalSeconds %60;
		var totalMinutes = Math.floor(totalSeconds /60);
		var hours = Math.floor(totalMinutes /60);
		var minutes = totalMinutes -(hours *60);
		return `${hours >0? (hours +":") : ""}${minutes <10 && hours >0? "0" +minutes : minutes}:${seconds <10? "0" +seconds : seconds}`;
	}

	acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton
	onClicked: (mouse) => { switch (mouse.button) {
		case Qt.LeftButton:
			popout.toggle();
			break;
		case Qt.MiddleButton:
			Service.MPlayer.player.togglePlaying();
			break;
		case Qt.BackButton:
			Service.MPlayer.player.previous();
			break;
		case Qt.ForwardButton:
			Service.MPlayer.player.next();
			break;
	}}
	onWheel: (wheel) => {
		const enabled = Service.MPlayer.player?.canSeek && Service.MPlayer.player?.positionSupported;
		if (enabled) {
			let position = Service.MPlayer.player.position;
			position += (wheel.angleDelta.y /120) *5;
			Service.MPlayer.player.position = Math.min(Math.max(position, 0.0), Service.MPlayer.player.length);
		}
	}
	icon: GridLayout { id: icon
		columns: {
			const h = root.height -Globals.Controls.padding *(4 /3);

			if (h >= 24) return 1;
			else return 2;
		}
		rows: 2 /columns
		width: Service.MPlayer.active? (160 *icon.columns) : 0
		flow: Grid.TopToBottom

		Item {
			Layout.columnSpan: 2
			Layout.alignment: Qt.AlignHCenter
			Layout.fillWidth: true
			Layout.maximumWidth: Math.min(childrenRect.width, 210)
			Layout.preferredHeight: childrenRect.height
			clip: true

			Ctrl.Marquee {
				scrolling: parent.width < content.width && (root.containsMouse || popout.isOpen)
				content: Row {
					spacing: Globals.Controls.spacing

					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: Service.MPlayer.title
						color: Globals.Colours.text
						font.pointSize: 8
					}

					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: Service.MPlayer.artist
						color: Globals.Colours.light
						font.pointSize: 8
						font.italic: true
					}
				}
			}
		}

		// display the elapsed time of the track as a % of the total track length
		Style.Slider {
			Layout.fillWidth: true
			from: 0.0
			value: Service.MPlayer.player?.position || 0.0
			to: Service.MPlayer.player?.length || 1.0
		}

		Text {
			visible: icon.columns < 2
			text: `${root.formatTime(parseInt(Service.MPlayer.player?.position || 0.0))}/${root.formatTime(parseInt(Service.MPlayer.player?.length || 0.0))}`
			color: Globals.Colours.text_inactive
			font.family: Globals.Font.mono
			font.pointSize: 6
		}
	}

	Ctrl.Popout { id: popout
		content: Style.PageLayout { id: layout
			body: Item { id: body // album art
				implicitWidth: Math.min(120, art.sourceSize.height) *(art.sourceSize.height /art.sourceSize.width)
				width: Math.max(implicitWidth, layout.width)
				height: width *(art.sourceSize.height /art.sourceSize.width)
				layer.enabled: true
				layer.effect: OpacityMask { maskSource: Rectangle {
					width: body.width; height: body.height;
					radius: Globals.Controls.radius
				}}

				RectangularShadow {
					anchors.fill: art
					radius: Globals.Controls.radius *(3 /4)
					blur: parent.width
					color: Service.MPlayer.accent
				}

				RectangularShadow {
					anchors.fill: art
					blur: 8
					opacity: 0.4
				}

				Image { id: art
					anchors.centerIn: parent
					height: parent.height -Globals.Controls.padding *2; width: parent.width -Globals.Controls.padding *2;
					source: Service.MPlayer.artUrl
					retainWhileLoading: true
					mipmap: true
					layer.enabled: true
					layer.effect: OpacityMask { maskSource: Rectangle {
						width: art.width
						height: art.height
						radius: Globals.Controls.radius *(3 /4)
					}}
				}
			}
			footer: Row { //controls
				padding: Globals.Controls.spacing

				Ctrl.Button { // shuffle
					enabled: Service.MPlayer.player?.shuffleSupported || false
					onClicked: if (enabled) ;
					icon: IconImage {
						implicitSize: 24
						source: Service.MPlayer.player?.shuffle? Quickshell.iconPath("media-playlist-shuffle-symbolic") : Quickshell.iconPath("media-playlist-no-shuffle-symbolic")
					}
				}
				Ctrl.Button { // previous track
					onClicked: Service.MPlayer.player.previous();
					icon: IconImage {
						implicitSize: 24
						source: Quickshell.iconPath("media-skip-backward-symbolic")
					}
				}
				Ctrl.Button { // play/pause
					onClicked: Service.MPlayer.player.togglePlaying();
					icon: IconImage {
						implicitSize: 24
						source: Service.MPlayer.player?.isPlaying? Quickshell.iconPath("media-playback-pause-symbolic") : Quickshell.iconPath("media-playback-start-symbolic")
					}
				}
				Ctrl.Button { // next track
					onClicked: Service.MPlayer.player.next();
					icon: IconImage {
						implicitSize: 24
						source: Quickshell.iconPath("media-skip-forward-symbolic")
					}
				}
				Ctrl.Button { // loop
					enabled: Service.MPlayer.player?.loopSupported || false
					onClicked: if (enabled) Service.MPlayer.loopState();
					icon: IconImage {
						implicitSize: 24
						source: switch (Service.MPlayer.player?.loopState) {
							case MprisLoopState.None:
								return Quickshell.iconPath("media-playlist-no-repeat-symbolic");
							case MprisLoopState.Playlist:
								return Quickshell.iconPath("media-playlist-repeat-symbolic");
							case MprisLoopState.Track:
								return Quickshell.iconPath("media-playlist-repeat-song-symbolic");
							default:
								return "";
						}
					}
				}
			}
		}
	}

	Connections {
		target: Service.MPlayer

		function onActiveChanged() { popout.isOpen = false; }
	}
}
