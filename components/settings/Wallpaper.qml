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
	property string path: "/home/andrel/Pictures/Wallpapers/"

	spacing: Globals.Controls.padding
	width: parent.width

	Rectangle { id: preview
		readonly property size resolution: root.wallpapers[0]?.resolution || null

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
			color: Globals.Colours.accent
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Rectangle {
				width: previewContainer.width
				height: previewContainer.height
				radius: 2
			}}

			Image { id: previewImage
				anchors.fill: parent
				source: Service.Swww.wallpapers[0]?.path || ''
				asynchronous: true
				mipmap: true
				fillMode: switch (true) {
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

	Item {
		Layout.fillWidth: true;
		Layout.fillHeight: true;

		ScrollView { id: scrollview
			anchors.fill: parent
			padding: Globals.Controls.spacing +Globals.Controls.radius*(3 /4)
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
				hoverEnabled: grid.height > scrollview.height
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
				cellHeight: 90
				cellWidth: 160
				highlightFollowsCurrentItem: true
				highlightMoveDuration: 0
				highlight: Rectangle {
					color: "transparent"
					border { width: Globals.Controls.spacing; color: Globals.Colours.accent; }
				}
				model: []
				delegate: Item { id: delegate
					required property var modelData
					required property int index

					width: grid.cellWidth; height: grid.cellHeight;

					Rectangle {
						anchors.centerIn: parent
						width: parent.width -Globals.Controls.spacing *2; height: parent.height -Globals.Controls.spacing *2;
						color: Qt.alpha(Globals.Colours.accent, 1.0 /grid.count *(grid.count -delegate.index))

						Image { id: thumbnail
							anchors.fill: parent
							source: `${root.path}${delegate.modelData}` ?? "/home/andrel/Pictures/Wallpapers/wallhaven-rqy6wm.jpg"
							sourceSize: Qt.size(thumbnail.width, thumbnail.height)
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
						const idx = grid.indexAt(mouse.x, mouse.y);

						if (idx !== -1) grid.currentIndex = idx;
					}
				}
			}
		}
	}

	Ctrl.Button {
		Layout.fillWidth: true
		icon: Text {
			text: "Apply"
			color: Globals.Colours.text
			font.pointSize: 10
			font.weight: 600
			font.letterSpacing: 1.0
		}

		ShaderEffectSource {
			anchors.fill: parent
			z: -999
			sourceItem: parent.background
			opacity: 0.1
		}
	}

	// FileView { id: fileview
	// 	path: Qt.resolvedUrl("./wall.json")
	// 	onLoaded: {
	// 		position.currentIndex = fileview.adapter.position;
	// 		transition.currentIndex = fileview.adapter.transition;
	// 		root.fillColour = fileview.adapter.fill;
	// 	}
 //
	// 	JsonAdapter {
	// 		property int position: position.currentIndex
	// 		property int transition: transition.currentIndex
	// 		property color fill: root.fillColour
	// 	}
	// }

	Process { id: getWalls
		running: true
		command: ['ls', '-p1', root.path]
		stdout: StdioCollector { onStreamFinished: {
			const formats = ['.jpg', '.jpeg', '.png', '.gif', '.pnm', '.tga', '.tiff', '.webp', '.bmp', '.farbfeld', '.svg'];
			const model = text
				.trim()
				.split('\n')
				.filter(w => !w.endsWith('/'))
				.filter(w => formats.some(f => w.endsWith(f)));

			grid.model = model;
			grid.currentIndex = model.findIndex(w => `${root.path}${w}` == Service.Swww.wallpapers[0]?.path || '') ?? -1;
		}}
	}
}
