pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import qs.controls as Ctrl
import "../../globals.js" as Globals

ColumnLayout { id: root
	property list<var> wallpapers: []
	property color fillColour: Globals.Colours.accent

	width: parent.width

	Rectangle { id: preview
		readonly property size resolution: root.wallpapers[display.currentIndex]?.resolution || null

		Layout.fillWidth: true
		Layout.minimumWidth: 480
		Layout.preferredHeight: width *(9 /16)
		radius: Globals.Controls.radius *(3 /4)
		color: Globals.Colours.dark

		Rectangle { id: previewContainer
			visible: previewImage.status === Image.Ready
			x: parent.width /2 -width /2
			y: (parent.height -height) *(1 /3)
			width: parent.width -24
			height: parent.height -36
			color: root.fillColour
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Rectangle {
				width: previewContainer.width
				height: previewContainer.height
				radius: 2
			}}

			Image { id: previewImage
				anchors.centerIn: parent
				width: {
					if (position.model[position.currentIndex].toLowerCase() === "no") return parent.width *(sourceSize.width /preview.resolution.width);
					else return parent.width;
				}
				height: {
					if (position.model[position.currentIndex].toLowerCase() === "no") return parent.height *(sourceSize.height /preview.resolution.height);
					else return parent.height;
				}
				source: root.wallpapers[display.currentIndex]?.path || ''
				mipmap: true
				fillMode: switch (position.model[position.currentIndex].toLowerCase()) {
					case "no":
						return Image.Stretch;
					case "crop":
						return Image.PreserveAspectCrop;
					case "fit":
						return Image.PreserveAspectFit;
					case "stretch":
						return Image.Stretch;
					default:
						return Image.PreserveAspectCrop;
				}
			}
		}
	}

	RowLayout {
		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height

			Rectangle { anchors.fill: parent; radius: Globals.Controls.radius *(3 /4); color: Globals.Colours.dark; opacity: 0.2; }

			Ctrl.Dropdown { id: display
				width: parent.width
				compatibilityMode: true
				model: [...root.wallpapers.map(w => w.display)]
			}
		}

		Item { id: pathWrapper
			readonly property TextMetrics metric: TextMetrics {
				text: path.icon.text
				font.pointSize: path.icon.font.pointSize
			}

			Layout.fillWidth: true
			Layout.maximumWidth: Math.floor(metric.width) +1 +Globals.Controls.padding
			Layout.preferredHeight: childrenRect.height

			Rectangle { anchors.fill: parent; radius: Globals.Controls.radius *(3 /4); color: Globals.Colours.dark; opacity: 0.2; }

			Ctrl.Button { id: path
				width: parent.width
				height: icon.height
				onClicked: if (!setWallpaper.running) setWallpaper.running = true;
				icon: Text {
					padding: Globals.Controls.spacing
					leftPadding: 0; rightPadding: 0;
					x: Globals.Controls.padding /2
					width: pathWrapper.width -Globals.Controls.padding
					text: root.wallpapers[0]?.path || ''
					elide: Text.ElideLeft
					color: Globals.Colours.text
					font.pointSize: 10
				}
			}
		}
	}

	RowLayout {
		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height

			Rectangle { anchors.fill: parent; radius: Globals.Controls.radius *(3 /4); color: Globals.Colours.dark; opacity: 0.2; }

			Ctrl.Dropdown { id: position
				width: parent.width
				compatibilityMode: true
				model: ['Crop', 'Fit', 'Stretch', 'No']
			}
		}

		Ctrl.Button {
			onClicked: if (!getColour.running) getColour.running = true;
			icon: Rectangle {
				width: Globals.Controls.iconSize; height: width;
				radius: 3
				color: root.fillColour
			}
		}

		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height

			Rectangle { anchors.fill: parent; radius: Globals.Controls.radius *(3 /4); color: Globals.Colours.dark; opacity: 0.2; }

			Ctrl.Dropdown { id: transition
				width: parent.width
				compatibilityMode: true
				model: ['None', 'Simple', 'Fade', 'Left', 'Right', 'Top', 'Bottom', 'Wipe', 'Wave', 'Grow', 'Center', 'Any', 'Outer', 'Random']
			}
		}
	}

	Item { id: applyWrapper
		readonly property TextMetrics metric: TextMetrics {
			text: apply.icon.text
			font.pointSize: apply.icon.font.pointSize
		}

		Layout.fillWidth: true
		// Layout.maximumWidth: Math.floor(metric.width) +1 +Globals.Controls.padding
		Layout.preferredHeight: childrenRect.height

		Rectangle { anchors.fill: parent; radius: Globals.Controls.radius *(3 /4); color: Globals.Colours.dark; opacity: 0.2; }

		Ctrl.Button { id: apply
			width: parent.width
			height: icon.height
			onClicked: if (!applyWallpaper.running) applyWallpaper.running = true;
			icon: Text {
				padding: Globals.Controls.spacing
				leftPadding: 0; rightPadding: 0;
				x: Globals.Controls.padding /2
				width: applyWrapper.width -Globals.Controls.padding
				text: "Apply"
				horizontalAlignment: Text.AlignHCenter
				elide: Text.ElideLeft
				color: Globals.Colours.text
				font.pointSize: 10
			}
		}
	}

	Item { Layout.fillHeight: true; }

	Process { id: getWallpaper
		running: true
		command: ['swww', 'query']
		stdout: StdioCollector {
			onStreamFinished: {
				var ws = text.trim().split('\n');

				root.wallpapers = [];

				for (let w of ws) {
					const parts = w.match(/^:\s*(\S+):\s*([^,]+),\s*scale:\s*(\d+),\s*currently displaying:\s*(\w+):\s*(.+)$/);

					if (!parts) continue;

					root.wallpapers.push({
						display: parts[1],
						resolution: parts[2],
						scale: parts[3],
						type: parts[4],
						path: parts[5]
					});
				}
			}
		}
	}

	Process { id: setWallpaper
		command: ['zenity', '--file-selection']
		stdout: StdioCollector {
			onStreamFinished: {
				if (text.trim()) {
					root.wallpapers[display.currentIndex].path = text.trim()

					console.log(`Settings: Wallpaper on ${root.wallpapers[display.currentIndex].display} changed to ${root.wallpapers[display.currentIndex].path}`);
				}
			}
		}
	}

	Process { id: getColour
		command: ['yad', '--color']
		stdout: StdioCollector { onStreamFinished: { if (text.trim()) root.fillColour = text.trim(); }}
	}

	Process { id: applyWallpaper
		command: ['swww', 'img', '--resize', position.model[position.currentIndex].toLowerCase(),
		'--fill-color', root.fillColour.toString().replace('#', ''),
		'-t', transition.model[transition.currentIndex].toLowerCase(), '--transition-fps', '60',
		root.wallpapers[display.currentIndex]?.path || '']
		stdout: StdioCollector { onStreamFinished: getWallpaper.running = true; }
	}
}
