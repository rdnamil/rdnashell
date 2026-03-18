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
	onClicked: popout.toggle();
	icon: GridLayout { id: icon
		columns: {
			const h = root.height -Globals.Controls.padding *(4 /3);

			if (h >= 24) return 1;
			else return 2;
		}
		width: Service.MPlayer.active? (160 *icon.columns) : 0

		Item {
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
	}

	Ctrl.Popout { id: popout
		content: Style.PageLayout {
			body: Rectangle { id: rect
				width: layout.width +Globals.Controls.spacing *2; height: layout.height +Globals.Controls.spacing *2;
				color: "transparent"
				layer.enabled: true
				layer.effect: OpacityMask {
					invert: true
					maskSource: Rectangle {
						width: rect.width; height: rect.height;
						radius: Globals.Controls.radius
						color: "transparent"
						border { width: 1; color: "#80ffffff"; }
					}
				}

				Rectangle {
					anchors.fill: parent
					gradient: Gradient {
						orientation: Gradient.Horizontal

						GradientStop { position: 0.0; color: Service.MPlayer.accent; }
						GradientStop { position: 0.4; color: Service.MPlayer.accent; }
						GradientStop { position: 1.0; color: Service.MPlayer.complementary; }
					}
					opacity: 0.1
				}

				GridLayout { id: layout
					anchors.centerIn: parent
					rows: 2
					rowSpacing: 0
					columns: 6
					columnSpacing: Globals.Controls.spacing

					Item { // album art
						Layout.rowSpan: 2
						Layout.preferredWidth: height
						Layout.fillHeight: true

						RectangularShadow {
							anchors.fill: art
							radius: Globals.Controls.radius *(3 /4)
							offset.x: Globals.Controls.spacing
							blur: 30
							opacity: 0.4
						}

						Image { id: art
							anchors.fill: parent
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

					RowLayout {
						Layout.columnSpan: 5

						Ctrl.Button {
							enabled: false
							icon: IconImage {
								implicitSize: 16
								source: Quickshell.iconPath("audio-volume-high-symbolic")
							}
						}

						Style.Slider { id: volumeSlider
							readonly property bool enabled: Service.MPlayer.player?.canControl && Service.MPlayer.player?.volumeSupported || false

							Layout.rightMargin: Globals.Controls.spacing
							Layout.fillWidth: true
							value: Service.MPlayer.player?.volume || 1.0
							onMoved: if (enabled) { Service.MPlayer.player.volume = volumeSlider.value; }
						}
					}
				}
			}
		}
	}
}
