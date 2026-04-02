pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	property int notifyOn: 0

	onClicked: popout.toggle();
	icon: IconImage {
		implicitSize: Globals.Controls.iconSize
		source: Quickshell.iconPath("package")
	}
	displayedIcon.layer.enabled: true
	displayedIcon.layer.effect: OpacityMask {
		invert: true
		maskSource: Item {
			width: root.displayedIcon.width; height: root.displayedIcon.height;

			Rectangle {
				x: parent.width -width /2; y: -height /4
				width: 10; height: width; radius: height /2;
				color: list.model.length >= root.notifyOn? "red" : "transparent"
			}
		}
	}

	Rectangle {
		visible: list.model.length >= root.notifyOn
		x: parent.width -width /2; y: parent.displayedIcon.y -height /4;
		width: 8; height: width; radius: height /2;
		color: Globals.Colours.danger
	}

	Ctrl.Popout { id: popout
		content: Style.PageLayout { id: content
			header: RowLayout {
				width: content.width

				Ctrl.Button {
					Layout.margins: Globals.Controls.spacing
					enabled: !Service.Updates.lock
					onClicked: Service.Updates.checkUpdates();
					icon: IconImage {
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("view-refresh")
					}
					opacity: enabled? 1.0 : 0.25
				}

				Ctrl.Button {
					Layout.alignment: Qt.AlignRight
					Layout.margins: Globals.Controls.spacing
					enabled: !Service.Updates.lock && list.model.length > 0
					onClicked: if (enabled) {
						Service.Updates.update();
						popout.isOpen = false;
					}
					icon: IconImage {
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("draw-arrow-down")
					}
					opacity: enabled? 1.0 : 0.25
				}
			}
			body: Ctrl.List { id: list
				view.spacing: Globals.Controls.spacing
				view.highlight: Item {}
				view.reuseItems: true
				model: [...Service.Updates.updates]
					.filter(u => u.package)
					.sort((a, b) => {
						if (a.repo.localeCompare(b.repo)) return a.repo.localeCompare(b.repo);
						else return a.package.localeCompare(b.package);
					})
				delegate: Item { id: delegate
					required property var modelData
					required property int index

					width: list.availableWidth
					height: childrenRect.height

					Rectangle {
						anchors.fill: parent
						color: Globals.Colours.light
						opacity: delegate.index %2 === 1? 0.25 : 0.0
					}

					RowLayout { id: layout
						width: parent.width

						Text {
							readonly property TextMetrics metric: TextMetrics {
								text: list.model.length
								font.family: Globals.Font.mono
								font.pointSize: 10
							}

							Layout.leftMargin: Globals.Controls.spacing
							Layout.preferredWidth: metric.width
							text: list.model.length -delegate.index
							horizontalAlignment: Text.AlignRight
							color: Globals.Colours.accent
							font.family: Globals.Font.mono
							font.pointSize: 10
						}

						Text {
							readonly property color flavour: switch (delegate.modelData.repo) {
								case "endeavouros": return "#c6a0f6";
								case "core": return "#eed49f";
								case "extra": return "#a6da95";
								case "multilib": return "#8bd5ca";
								case "aur": return "#8aadf4"
								default: return "#eed49f";
							}

							Layout.leftMargin: Globals.Controls.spacing
							Layout.fillWidth: true
							text: `<font color="${flavour}">${delegate.modelData.repo}</font>/${delegate.modelData.package}`
							elide: Text.ElideRight
							color: Globals.Colours.text
							font.pointSize: 8
						}

						Text {
							readonly property var splitByCommonPrefix: {
								const a = delegate.modelData.current;
								const b = delegate.modelData.new;
								let i = 0;
								const minLength = Math.min(a.length, b.length);
								while (i < minLength && a[i] === b[i]) i++;

								return {
									common: a.slice(0, i),
									diffA: a.slice(i),
									diffB: b.slice(i)
								};
							}

							Layout.rightMargin: Globals.Controls.spacing
							text: `${splitByCommonPrefix.common}<font color="${Globals.Colours.danger}">${splitByCommonPrefix.diffA}</font> -> ${splitByCommonPrefix.common}<font color="${Globals.Colours.success}">${splitByCommonPrefix.diffB}</font>`
							color: Globals.Colours.text
							font.pointSize: 6
						}
					}
				}
			}
		}
	}
}
