pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
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
					if (position.model[position.currentIndex].text.toLowerCase() === "no") return parent.width *(sourceSize.width /preview.resolution.width);
					else return parent.width;
				}
				height: {
					if (position.model[position.currentIndex].text.toLowerCase() === "no") return parent.height *(sourceSize.height /preview.resolution.height);
					else return parent.height;
				}
				source: root.wallpapers[display.currentIndex]?.path || ''
				mipmap: true
				fillMode: switch (position.model[position.currentIndex].text.toLowerCase()) {
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

	ScrollView { id: recentScrollView
		Layout.fillWidth: true
		Layout.maximumWidth: preview.width
		Layout.preferredHeight: 124
		padding: Globals.Controls.padding
		background: Rectangle {
			anchors.fill: parent
			radius: Globals.Controls.radius
			color: Globals.Colours.dark
			opacity: 0.2
		}

		ListView { id: listView
			spacing: Globals.Controls.padding
			orientation: ListView.Horizontal
			clip: true
			model: ScriptModel {
				values: fileview.adapter.recent
				objectProp: "filename"
			}
			delegate: Image { id: delegate
				required property var modelData
				required property int index

				width: height *(sourceSize.width /sourceSize.height)
				height: recentScrollView.availableHeight
				source: modelData.path
				fillMode: Image.PreserveAspectFit
				mipmap: true
				asynchronous: true

				Rectangle {
					visible: delegate.index == listView.currentIndex
					anchors.fill: parent
					color: "transparent"
					border { width: 3; color: Globals.Colours.accent; }
				}
			}

			MouseArea { id: mouseArea
				anchors.fill: parent
				onClicked: (mouse) => {
					const idx = listView.indexAt(mouse.x +listView.contentX, mouse.y);

					if (idx != -1) {
						listView.currentIndex = idx;
						root.wallpapers[display.currentIndex].path = listView.model.values[idx].path;
					}
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
				model: root.wallpapers.map(w => {
					return {"text": w.display};
				})
			}
		}

		Item { id: pathWrapper
			readonly property TextMetrics metric: TextMetrics {
				text: pathText.text
				font.pointSize: pathText.font.pointSize
			}

			Layout.fillWidth: true
			Layout.maximumWidth: Globals.Controls.iconSize +Globals.Controls.spacing *3 +Globals.Controls.padding /2 +metric.width +1
			Layout.preferredHeight: childrenRect.height

			Rectangle { anchors.fill: parent; radius: Globals.Controls.radius *(3 /4); color: Globals.Colours.dark; opacity: 0.2; }

			Ctrl.Button { id: path
				width: parent.width
				height: icon.height
				onClicked: if (!setWallpaper.running) setWallpaper.running = true;
				icon: RowLayout {
					spacing: 0
					width: pathWrapper.width

					IconImage {
						Layout.margins: Globals.Controls.spacing
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("image-x-generic")
					}

					Text { id: pathText
						Layout.margins: Globals.Controls.spacing
						Layout.rightMargin: Globals.Controls.padding /2
						Layout.fillWidth: true
						text: root.wallpapers[0]?.path || ''
						elide: Text.ElideLeft
						color: Globals.Colours.text
						font.pointSize: 10
					}
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
				model: [{"text":"Crop"}, {"text":"Fit"}, {"text":"Stretch"}, {"text":"No"}]
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
				model: [{"text":"None"}, {"text":"Simple"}, {"text":"Fade"}, {"text":"Left"}, {"text":"Right"}, {"text":"Top"}, {"text":"Bottom"}, {"text":"Wipe"}, {"text":"Wave"}, {"text":"Grow"}, {"text":"Center"}, {"text":"Any"}, {"text":"Outer"}, {"text":"Random"}]
			}
		}
	}

	// Item { Layout.preferredHeight: 24; }

	Item { id: applyWrapper
		Layout.fillWidth: true
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

	FileView { id: fileview
		path: Qt.resolvedUrl("./wall.json")
		onLoaded: {
			position.currentIndex = fileview.adapter.position;
			transition.currentIndex = fileview.adapter.transition;
			root.fillColour = fileview.adapter.fill;
		}

		JsonAdapter {
			property list<var> recent
			property int position: position.currentIndex
			property int transition: transition.currentIndex
			property color fill: root.fillColour

			onRecentChanged: if (recent.length > 10) recent.splice(10, 1);
		}
	}

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
				const path = text.trim();

				if (path.length > 0) {
					root.wallpapers[display.currentIndex].path = path;

					if (!fileview.adapter.recent.some(w => w.path === path)) {
						fileview.adapter.recent.splice(0, 0, {
							"path": path,
							"filename": path.split('/').pop()
						});
						listView.currentIndex = 0;
					}
					else listView.currentIndex = fileview.adapter.recent.findIndex(w => w.path === path);

					// console.log(`Settings: Wallpaper on ${root.wallpapers[display.currentIndex].display} changed to ${root.wallpapers[display.currentIndex].path}`);
				}
			}
		}
	}

	Process { id: getColour
		command: ['yad', '--color']
		stdout: StdioCollector { onStreamFinished: { if (text.trim()) root.fillColour = text.trim(); }}
	}

	Process { id: applyWallpaper
		command: ['swww', 'img', '--resize', position.model[position.currentIndex].text.toLowerCase(),
		'--fill-color', root.fillColour.toString().replace('#', ''),
		'-t', transition.model[transition.currentIndex].text.toLowerCase(), '--transition-fps', '60',
		root.wallpapers[display.currentIndex]?.path || '']
		stdout: StdioCollector { onStreamFinished: { getWallpaper.running = true; fileview.writeAdapter(); }}
	}
}
