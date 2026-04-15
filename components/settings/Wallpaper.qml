pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../../globals.js" as Globals

ColumnLayout { id: root
	property string path: `${Quickshell.env("HOME")}/Pictures/Wallpapers`

	spacing: Globals.Controls.padding
	width: parent.width

	Rectangle { id: preview
		readonly property size resolution: Service.Awww.wallpapers[0]?.resolution || null

		Layout.alignment: Qt.AlignHCenter
		Layout.fillWidth: true
		Layout.minimumWidth: 480
		Layout.maximumWidth: 720
		Layout.preferredHeight: width *(9 /16)
		radius: Globals.Controls.radius *(3 /4)
		color: Globals.Colours.dark

		Rectangle { id: previewContainer
			visible: previewImage.status === Image.Ready
			x: parent.width /2 -width /2
			y: (parent.height -height) *(1 /3)
			width: parent.width -24
			height: parent.height -36
			color: Globals.Colours.accent
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Rectangle {
				width: previewContainer.width
				height: previewContainer.height
				radius: 2
			}}

			Image { id: previewImage
				anchors.fill: parent
				source: grid.currentItem?.wallpaper || ''
				cache: true
				asynchronous: true
				mipmap: true
				fillMode: switch (resize.model[resize.currentIndex].text.toLowerCase()) {
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
		spacing: Globals.Controls.spacing

		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height

			Ctrl.Dropdown { id: resize
				width: parent.width
				compatibilityMode: true
				currentIndex: 1
				model: ['No', 'Crop', 'Fit', 'Stretch'].map(r => {
					return {"text":r};
				})

				ShaderEffectSource {
					anchors.fill: parent
					z: -999
					sourceItem: parent.button.background
					opacity: 0.1
				}
			}
		}

		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height

			Ctrl.Dropdown { id: transition
				width: parent.width
				compatibilityMode: true
				currentIndex: 1
				model: ['None', 'Simple', 'Fade', 'Left', 'Right', 'Top', 'Bottom', 'Wipe', 'Wave', 'Grow', 'Center', 'Any', 'Outer', 'Random'].map(r => {
					return {"text":r};
				})

				ShaderEffectSource {
					anchors.fill: parent
					z: -999
					sourceItem: parent.button.background
					opacity: 0.1
				}
			}
		}

		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height

			Ctrl.Button { id: path
				width: parent.width
				height: transition.height
				enabled: !getPath.running
				onClicked: if (enabled) getPath.running = true;
				icon: RowLayout {
					spacing: Globals.Controls.spacing
					width: path.width

					IconImage {
						Layout.leftMargin: Globals.Controls.spacing
						implicitSize: txt.height
						source: Quickshell.iconPath("folder")
					}

					Text { id: txt
						Layout.rightMargin: Globals.Controls.spacing
						Layout.fillWidth: true
						text: root.path
						elide: Text.ElideLeft
						color: path.enabled? Globals.Colours.text : Globals.Colours.mid
						font.pointSize: 8
					}
				}

				ShaderEffectSource {
					anchors.fill: parent
					z: -999
					sourceItem: parent.background
					opacity: parent.enabled? 0.1 : 0.0
				}
			}
		}
	}

	Item {
		Layout.fillWidth: true;
		Layout.fillHeight: true;

		ScrollView { id: scrollview
			anchors.fill: parent
			padding: Globals.Controls.spacing +Globals.Controls.radius*(3 /4)
			leftPadding: (width %grid.cellWidth) /2
			clip: true
			background: Rectangle {
				radius: Globals.Controls.radius*(3 /4)
				color: Globals.Colours.dark
				opacity: 0.4
			}
			ScrollBar.horizontal: ScrollBar { hoverEnabled: false; }
			ScrollBar.vertical: ScrollBar { id: scrollBar
				x: scrollview.width -width /2 -Globals.Controls.padding
				y: scrollview.padding
				height: scrollview.availableHeight
				hoverEnabled: grid.contentHeight > scrollview.height
				contentItem: Rectangle {
					implicitWidth: scrollBar.active? 6 : 4
					radius: width /2
					color: scrollBar.active? Globals.Colours.text : Globals.Colours.mid
					opacity: (scrollBar.active && scrollBar.size < 1.0) ? 0.75 : 0

					Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
					Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
					Behavior on color { ColorAnimation { duration: 250; }}
				}
			}

			GridView { id: grid
				cellWidth: 160
				cellHeight: 90
				clip: true
				onCurrentItemChanged: {
					if (contentY > currentItem.y) contentY = currentItem.y;
					else if ((contentY +height) < (currentItem.y +currentItem.height)) contentY = currentItem.y -height +currentItem.height;
				}
				highlightFollowsCurrentItem: false
				highlightMoveDuration: 0
				highlight: Rectangle {
					anchors.centerIn: grid.currentItem
					width: grid.cellWidth -Globals.Controls.spacing; height: grid.cellHeight -Globals.Controls.spacing;
					color: "transparent"
					radius: Globals.Controls.radius *(1 /2)
					border { width: Globals.Controls.spacing /2; color: Globals.Colours.accent; }

					Rectangle {
						anchors.centerIn: parent
						width: parent.width -Globals.Controls.spacing +2; height: parent.height -Globals.Controls.spacing +2;
						border { width: 1; color: Qt.alpha("black", 0.2); }
					}
				}
				model: []
				delegate: Item { id: delegate
					required property var modelData
					required property int index

					readonly property url wallpaper: `${root.path}/${delegate.modelData}`

					width: grid.cellWidth; height: grid.cellHeight;

					Rectangle {
						anchors.centerIn: parent
						width: parent.width -Globals.Controls.spacing *2; height: parent.height -Globals.Controls.spacing *2;
						color: Qt.alpha(Globals.Colours.accent, 1.0 /grid.count *(grid.count -delegate.index))

						Image { id: thumbnail
							anchors.fill: parent
							source: delegate.wallpaper
							sourceSize: Qt.size(thumbnail.width, thumbnail.height)
							fillMode: Image.PreserveAspectCrop
							cache: true
							mipmap: true
							asynchronous: true
						}

						Rectangle {
							anchors.fill: parent
							color: Globals.Colours.accent
							opacity: {
								const x = mousearea.mouseX >= delegate.x && mousearea.mouseX <= delegate.x +delegate.width;
								const y = mousearea.mouseY >= delegate.y -grid.contentY && mousearea.mouseY <= delegate.y -grid.contentY +delegate.height;

								return mousearea.containsMouse && x && y? 0.4 : 0.0;
							}
						}
					}
				}

				MouseArea { id: mousearea
					anchors.fill: parent
					hoverEnabled: true
					onClicked: (mouse) => {
						const idx = grid.indexAt(mouse.x, mouse.y +grid.contentY);

						if (idx !== -1) {
							grid.currentIndex = idx;
							previewImage.source = grid.itemAtIndex(idx).wallpaper;
						}
					}
				}
			}
		}
	}

	Ctrl.Button { id: applyBtn
		Layout.fillWidth: true
		enabled: grid.currentIndex !== -1
		onClicked: if (enabled) {
			Service.Awww.setWallpaper(grid.currentItem.wallpaper, transition.model[transition.currentIndex].text.toLowerCase(), resize.model[resize.currentIndex].text.toLowerCase());
			fileview.writeAdapter();
		}
		icon: Text {
			text: "Apply"
			color: applyBtn.enabled? Globals.Colours.text : Globals.Colours.mid
			font.pointSize: 10
			font.weight: 600
			font.letterSpacing: 1.0
		}

		ShaderEffectSource {
			anchors.fill: parent
			z: -999
			sourceItem: parent.background
			opacity: parent.enabled? 0.1 : 0.0
		}
	}

	FileView { id: fileview
		path: Qt.resolvedUrl("./wall.json")
		onLoaded: {
			resize.currentIndex = fileview.adapter.resize;
			transition.currentIndex = fileview.adapter.transition;
			root.path = fileview.adapter.path;
			getWalls.running = true;
		}

		JsonAdapter {
			property int resize: resize.currentIndex
			property int transition: transition.currentIndex
			property string path: root.path
		}
	}

	Process { id: getWalls
		command: ['ls', '-p1', root.path]
		stdout: StdioCollector { onStreamFinished: {
			const formats = ['.jpg', '.jpeg', '.png', '.gif', '.pnm', '.tga', '.tiff', '.webp', '.bmp', '.farbfeld', '.svg'];
			const model = text
				.trim()
				.split('\n')
				.filter(w => !w.endsWith('/'))
				.filter(w => formats.some(f => w.endsWith(f)));

			grid.model = model;
			grid.currentIndex = model.findIndex(w => `${root.path}/${w}` == Service.Awww.wallpapers[0]?.path || '') ?? -1;

			const minY = Math.max(0, grid.currentItem.y -Globals.Controls.padding)
			const maxY = Math.max(0, grid.contentHeight -grid.height);
			grid.contentY = Math.min(minY, maxY);
		}}
	}

	Process { id: getPath
		command: ['zenity', '--file-selection', '--directory']
		stdout: StdioCollector { onStreamFinished: {
			const path = text.trim();

			if (path.length) {
				root.path = path;
				getWalls.running = true;
			}
		}}
	}
}
