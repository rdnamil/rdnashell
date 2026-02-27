pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
    property list<var> info: []
    property list<var> updates: []
    property int notifyOn: 0
    property list<string> updateCommmand: []

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
        content: Style.PageLayout { id: layout
            header: RowLayout {
                width: layout.width

                Ctrl.Button {
                    Layout.margins: Globals.Controls.spacing
                    enabled: !getUpdates.running
                    onClicked: if (enabled) getUpdates.running = true;
                    icon: IconImage {
                        implicitSize: Globals.Controls.iconSize
                        source: Quickshell.iconPath("view-refresh")
                    }
                }

                Ctrl.Button {
                    Layout.alignment: Qt.AlignRight
                    Layout.margins: Globals.Controls.spacing
                    onClicked: if (!update.running) update.running = true;
                    icon: IconImage {
                        implicitSize: Globals.Controls.iconSize
                        source: Quickshell.iconPath("draw-arrow-down")
                    }
                }
            }
            body: Ctrl.List { id: list
                view.highlight: Item {}
                view.spacing: Globals.Controls.spacing
                model: []
                delegate: Item { id: delegate
                    required property var modelData
                    required property int index

                    width: list.availableWidth
                    height: delegateLayout.height

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width +Globals.Controls.spacing
                        height: parent.height +Globals.Controls.spacing
                        radius: Globals.Controls.radius *(3 /4)
                        color: Globals.Colours.light
                        opacity: delegate.index %2 === 1? 0.25 : 0.0
                    }

                    RowLayout { id: delegateLayout
                        width: list.availableWidth

                        Text {
                            readonly property TextMetrics metric: TextMetrics {
                                text: list.model.length
                                font.family: Globals.Font.mono
                                font.pointSize: 10
                            }

                            Layout.leftMargin: Globals.Controls.spacing
                            Layout.preferredWidth: metric.width
                            text: list.model.length -delegate.index
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

    Process { id: update
        command: root.updateCommmand
        stdout: StdioCollector { onStreamFinished: getUpdates.running = true; }
    }

    Process { id: getUpdates
        running: true
        command: ['checkupdates']
        stdout: StdioCollector { onStreamFinished: {
            root.updates = text.trim()
                .split('\n')
                .map(l => {
                    const p = l.split(' ');
                    return {
                        "package": p[0],
                        "current": p[1],
                        "new": p[3]
                    }
                });

            getAurUpdates.running = true;
        }}
    }

    Process { id: getAurUpdates
		command: ['yay', '-Qua']
		stdout: StdioCollector { onStreamFinished: {
			text.trim()
			.split('\n')
			.map(l => {
				const p = l.split(' ');
				return {
					"repo": "aur",
					"package": p[0],
					"current": p[1],
					"new": p[3]
				}
			})
			.forEach(u => root.updates.push(u));

			getInfo.running = true;
		}}
	}

	Process { id: getInfo
		// running: true
		command: ['pacman', '-Si']
		stdout: StdioCollector { onStreamFinished: {
			const updates = root.updates.map(p => p.package);
			text.trim()
			.split(/\n\s*\n/)
			.map(e => {
				const pkg = {};

				e.split('\n').forEach(l => {
					const match = l.match(/^([^:]+?)\s*:\s*(.*)$/);
					if (match) {
						const key = match[1].trim();
						const value = match[2].trim();
						pkg[key] = value;
					}
				});

				return pkg;
			})
			.filter(p => updates.includes(p.Name))
			.forEach(p => {
				root.updates.find(u => u.package === p.Name).repo = p.Repository;
			});

			list.model = root.updates
			.filter(u => u.package)
			.sort((a, b) => {
				if (a.repo.localeCompare(b.repo)) return a.repo.localeCompare(b.repo);
				else return a.package.localeCompare(b.package);
			});
			// console.log(root.info.map(p => p.Name));
		}}
	}

    Timer {
        interval: 36e5
        repeat: true
        onTriggered: if (!getUpdates.running) getUpdates.running = true;
    }
}
