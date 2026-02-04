/*-------------------------
--- Audio.qml by andrel ---
-------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	acceptedButtons: Qt.LeftButton | Qt.MiddleButton
	onClicked: event => { switch (event.button) {
		case Qt.LeftButton:
			popout.toggle();
			break;
		case Qt.MiddleButton:
			Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink?.audio.muted || false;
			break;
	}}
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: {
			if (Pipewire.defaultAudioSink?.audio.muted) return Quickshell.iconPath("audio-volume-off");
			else if (Pipewire.defaultAudioSink?.audio.volume < (1 /3)) return Quickshell.iconPath("audio-volume-low");
			else if (Pipewire.defaultAudioSink?.audio.volume < (2 /3)) return Quickshell.iconPath("audio-volume-medium");
			else return Quickshell.iconPath("audio-volume-high");
		}
	}

	Ctrl.Popout { id: popout
		content: Style.PageLayout { id: content
			body: ColumnLayout {
				spacing: 0
				width: 480

				Ctrl.Dropdown { id: drop
					readonly property list<PwNode> audioSinks: Pipewire.nodes.values.filter(n => n.isSink && n.description)

					Layout.fillWidth: true
					Layout.margins: Globals.Controls.spacing
					Layout.bottomMargin: 0
					tooltip: "select default device"
					currentIndex: audioSinks.findIndex(n => n === Pipewire.defaultAudioSink)
					onSelected: index => { Pipewire.preferredDefaultAudioSink = drop.audioSinks[index]; }
					model: audioSinks.map(n => n.description)
				}

				RowLayout { id: bodyLayout
					spacing: 0

					Ctrl.Button {
						Layout.margins: Globals.Controls.spacing
						onClicked: Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink?.audio.muted || false;
						icon: IconImage {
							implicitSize: Globals.Controls.iconSize
							source: { if (Pipewire.defaultAudioSink?.audio.muted) return Quickshell.iconPath("audio-volume-off");
								else return Quickshell.iconPath("audio-volume-high");
							}
						}
						tooltip: { if (Pipewire.defaultAudioSink?.audio.muted) return "unmute device";
							else return "mute device";
						}
					}

					Style.Slider {
						Layout.rightMargin: Globals.Controls.padding
						Layout.fillWidth: true
						value: Pipewire.defaultAudioSink?.audio.volume || 0.0
						onMoved: Pipewire.defaultAudioSink.audio.volume = value;
					}
				}
			}
			footer: ColumnLayout {
				spacing: 0
				width: content.body.width

				Repeater { id: repeater
					model: Pipewire.nodes.values.filter(n => n.isStream)
					delegate: RowLayout { id: delegate
						required property var modelData
						required property int index

						spacing: 0

						Ctrl.Button { id: btn
							readonly property string iconUrl: Quickshell.iconPath(delegate.modelData.properties["application.icon-name"], true)

							Layout.margins: Globals.Controls.spacing
							Layout.bottomMargin: delegate.index !== repeater.count -1? 0 : Globals.Controls.spacing
							onClicked: delegate.modelData.audio.muted = !delegate.modelData.audio.muted;
							faded: iconUrl !== '' && delegate.modelData.audio.muted
							icon: IconImage {
								implicitSize: Globals.Controls.iconSize
								source: {
									if (btn.iconUrl !== '') return btn.iconUrl;
									else if (delegate.modelData.audio.muted) return Quickshell.iconPath("audio-volume-off");
									else return Quickshell.iconPath("audio-volume-high");
								}
							}
							tooltip: { if (delegate.modelData.audio.muted) return "unmute";
								else return "mute";
							}
						}

						Style.Slider {
							Layout.alignment: Qt.AlignVCenter
							Layout.rightMargin: Globals.Controls.padding
							Layout.leftMargin: 0
							Layout.fillWidth: true
							value: delegate.modelData.audio.volume || 0.0
							onMoved: delegate.modelData.audio.volume = value;
						}
					}
				}
			}
		}
	}

	PwObjectTracker {
		objects: [Pipewire.defaultAudioSink, ...Pipewire.nodes.values.filter(n => n.isStream)]
	}
}
