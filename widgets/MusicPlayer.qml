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
	icon: RowLayout {
		width: 300

		Ctrl.Marquee {
			Layout.fillWidth: true
			Layout.maximumWidth: width
			scrolling: width < content.width && root.containsMouse
			content: RowLayout {
				spacing: Globals.Controls.spacing

				Text {
					text: Service.MPlayer.title
					color: Globals.Colours.text
					font.pointSize: 8
				}

				Text {
					text: Service.MPlayer.artist
					color: Globals.Colours.light
					font.pointSize: 8
					font.italic: true
				}
			}
		}

		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: 16
			Layout.minimumWidth: 150
		}
	}

	Ctrl.Popout { id: popout
		content: Style.PageLayout {
			body: Item {
				width: bodyLayout.width +Globals.Controls.padding *2
				height: bodyLayout.height +Globals.Controls.padding *2
				layer.enabled: true
				layer.effect: OpacityMask { maskSource: Rectangle {
					width: bodyLayout.width; height: bodyLayout.height; radius: Globals.Controls.radius;
				}}

				Image {
					anchors.fill: parent
					source: Service.MPlayer.artUrl
					fillMode: Image.PreserveAspectCrop
					retainWhileLoading: true
					mipmap: true
					opacity: 0.2
					layer.enabled: true
					layer.effect: FastBlur { radius: 30; }
				}

				RowLayout { id: bodyLayout
					anchors.centerIn: parent
					spacing: Globals.Controls.spacing
					width: 320

					Item {
						Layout.rightMargin: Globals.Controls.padding -parent.spacing
						Layout.preferredWidth: height *(art.sourceSize.width /art.sourceSize.height)
						Layout.fillHeight: true
						Layout.preferredHeight: art.sourceSize.height
						Layout.maximumHeight: 100

						RectangularShadow {
							anchors.fill: parent
							radius: Globals.Controls.radius *(3 /4)
							blur: 300
							spread: 30
							color: Service.MPlayer.accent
						}

						RectangularShadow {
							anchors.fill: parent
							radius: Globals.Controls.radius *(3 /4)
							blur: 15
							spread: 3
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

					IconImage { id: playerIcon
						Layout.alignment: Qt.AlignBottom
						implicitSize: 24
						source: Quickshell.iconPath(Service.MPlayer.player?.identity.toLowerCase())
					}

					Item {
						Layout.alignment: Qt.AlignBottom
						Layout.bottomMargin: playerIcon.height /2 -height /2
						Layout.fillWidth: true
						Layout.preferredHeight: childrenRect.height
						clip: true

						Ctrl.Marquee {
							scrolling: parent.width < width
							content: Row {
								spacing: Globals.Controls.spacing

								Text {
									text: Service.MPlayer.title
									color: Globals.Colours.text
									font.pointSize: 8
									font.weight: 600
									font.letterSpacing: 1.0
									layer.enabled: true
									layer.effect: MultiEffect {
										shadowEnabled: true
										shadowVerticalOffset: 1
										shadowOpacity: 0.8
										blurMax: 12
									}
								}

								Text {
									text: Service.MPlayer.artist
									color: Globals.Colours.text
									font.pointSize: 8
									// font.weight: 600
									font.letterSpacing: 1.0
									layer.enabled: true
									layer.effect: MultiEffect {
										shadowEnabled: true
										shadowVerticalOffset: 1
										shadowOpacity: 0.8
										blurMax: 12
									}
								}
							}
						}
					}
				}
			}
			footer: RowLayout {
				width: popout.content.width

				Row {
					padding: Globals.Controls.spacing

					Ctrl.Button {
						enabled: Service.MPlayer.player?.shuffleSupported || false
						onClicked: if (enabled) ;
						icon: IconImage {
							implicitSize: 24
							source: Service.MPlayer.player?.shuffle? Quickshell.iconPath("media-playlist-shuffle-symbolic") : Quickshell.iconPath("media-playlist-no-shuffle-symbolic")
						}
					}
					Ctrl.Button {
						onClicked: Service.MPlayer.player.previous();
						icon: IconImage {
							implicitSize: 24
							source: Quickshell.iconPath("media-skip-backward-symbolic")
						}
					}
					Ctrl.Button {
						onClicked: Service.MPlayer.player.togglePlaying();
						icon: IconImage {
							implicitSize: 24
							source: Service.MPlayer.player?.isPlaying? Quickshell.iconPath("media-playback-pause-symbolic") : Quickshell.iconPath("media-playback-start-symbolic")
						}
					}
					Ctrl.Button {
						onClicked: Service.MPlayer.player.next();
						icon: IconImage {
							implicitSize: 24
							source: Quickshell.iconPath("media-skip-forward-symbolic")
						}
					}
					Ctrl.Button {
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

				Rectangle {
					Layout.margins: Globals.Controls.padding
					Layout.leftMargin: 0
					Layout.fillWidth: true
					Layout.preferredHeight: 16
				}
			}
		}
	}
}
