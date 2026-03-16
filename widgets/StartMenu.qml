pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import "../globals.js" as Globals

Ctrl.Button { id: root
	property string fileManager: "thunar"
	property bool centreHorizontally

	height: parent.height
	width: icon.width
	icon: IconImage {
		implicitSize: {
			const h = root.height -Globals.Controls.padding *(4 /3);

			if (h >= 32) return 32;
			else if (h >= 24) return 24;
			else return 16;
		}
		source: Quickshell.iconPath("applications-all-symbolic")
	}
	background {
		anchors { fill: undefined; centerIn: root; }
		width: root.icon.width +Globals.Controls.padding *(2 /3);
		height: root.icon.height +Globals.Controls.padding *(2 /3);
	}
	onClicked: popout.toggle();

	Ctrl.Popout { id: popout
		centreHorizontally: root.centreHorizontally
		onOpen: {
			filters.view.currentIndex = 0;
			applications.view.currentIndex = -1;
		}
		content: Item { id: content
			width: childrenRect.width; height: childrenRect.height;
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Item {
				width: content.width; height: content.height;

				Rectangle { anchors.fill: parent; radius: Globals.Controls.radius}
			}}

			Rectangle {
				anchors.fill: parent
				radius: Globals.Controls.radius
				color: Globals.Colours.mid

				RectangularShadow {
					x: filters.x
					width: filters.width; height: filters.height;
					radius: parent.radius
					blur: 30
					opacity: 0.4
				}
			}

			RowLayout {
				spacing: 0

				Item {
					Layout.preferredWidth: childrenRect.width; Layout.preferredHeight: childrenRect.height;

					Column { id: col
						padding: Globals.Controls.padding /2
						spacing: Globals.Controls.padding
						width: 160

						Column { // user profile
							x: parent.width /2 -width /2

							Image {
								anchors.horizontalCenter: parent.horizontalCenter
								width: 64; height: width;
								source: Quickshell.iconPath("system-users")
								mipmap: true
							}

							Text {
								text: Service.ShellUtils.userFullName
								color: Globals.Colours.text
								font.pointSize: 12
								font.weight: 600
							}
						}

						Column { // shortcuts
							Repeater { id: shortcuts
								readonly property string homePath: Quickshell.env("HOME")

								model: ScriptModel {
									values: [
										{"name":"Home","icon":"folder-home","path":shortcuts.homePath},
										{"name":"Downloads","icon":"folder-downloads","path":`${shortcuts.homePath}/Downloads`},
										{"name":"Documents","icon":"folder-documents","path":`${shortcuts.homePath}/Documents`},
										{"name":"Pictures","icon":"folder-pictures","path":`${shortcuts.homePath}/Pictures`},
										{"name":"Music","icon":"folder-music","path":`${shortcuts.homePath}/Music`},
										{"name":"Videos","icon":"folder-videos","path":`${shortcuts.homePath}/Videos`},
									]
								}
								delegate: Ctrl.Button { id: shortcut
									required property var modelData

									height: icon.height +Globals.Controls.spacing

									onClicked:{
										Quickshell.execDetached([root.fileManager, shortcut.modelData.path]);
										popout.isOpen = false;
									}
									icon: RowLayout {
										width: col.width -col.padding *2 -Globals.Controls.padding
										spacing: Globals.Controls.spacing

										IconImage {
											implicitSize: 20
											source: Quickshell.iconPath(shortcut.modelData.icon, "folder")
										}

										Text {
											Layout.alignment: Qt.AlignVCenter
											Layout.fillWidth: true
											text: shortcut.modelData.name
											elide: Text.ElideRight
											color: Globals.Colours.text
											font.pointSize: 10
										}
									}
								}
							}
						}

						Column { // pins
							Repeater {
								model: Service.ShellUtils.pinView.adapter.pins
								delegate: Ctrl.Button { id: pin
									required property var modelData

									readonly property DesktopEntry entry: DesktopEntries.applications.values
									.find(a => a.id === pin.modelData)

									onClicked: {
										pin.entry?.execute();
										popout.isOpen = false;
									}
									height: icon.height +Globals.Controls.spacing
									icon: RowLayout {
										width: col.width -col.padding *2 -Globals.Controls.padding
										spacing: Globals.Controls.spacing

										IconImage {
											implicitSize: 20
											source: Quickshell.iconPath(pin.entry?.name.toLowerCase(), true) || Quickshell.iconPath(pin.modelData, "application-x-generic")
										}

										Text {
											Layout.alignment: Qt.AlignVCenter
											Layout.fillWidth: true
											text: pin.entry.name
											elide: Text.ElideRight
											color: Globals.Colours.text
											font.pointSize: 10
										}
									}
								}
							}
						}

						Row { // power options
							anchors.horizontalCenter: parent.horizontalCenter
							spacing: Globals.Controls.spacing

							Ctrl.Button {
								icon: IconImage {
									implicitSize: 24
									source: Quickshell.iconPath("system-lock-screen")
								}
							}

							Ctrl.Button {
								icon: IconImage {
									implicitSize: 24
									source: Quickshell.iconPath("system-log-out")
								}
							}

							Ctrl.Button {
								icon: IconImage {
									implicitSize: 24
									source: Quickshell.iconPath("system-shut-down")
								}
							}
						}
					}
				}

				Ctrl.List { id: filters
					Layout.preferredWidth: 160
					Layout.fillHeight: true
					Layout.preferredHeight: col.height
					padding: Globals.Controls.padding
					indexCanBeNull: false
					mouse.enabled: !popout.isTransitioning
					model: [
						{"name":"All Applications","icon":"applications-all","categories":[]},
						{"name":"Settings","icon":"applications-system","categories":["Settings"]},
						{"name":"Accessories","icon":"applications-accessories","categories":["Accessories", "Utility", "Recorder"]},
						{"name":"Development","icon":"applications-utilities","categories":["Development"]},
						{"name":"Education","icon":"applications-education","categories":["Education"]},
						{"name":"Games","icon":"applications-games","categories":["Game"]},
						{"name":"Graphics","icon":"applications-graphics","categories":["Graphics"]},
						{"name":"Internet","icon":"applications-internet","categories":["Internet", "Network", "WebBrowser"]},
						{"name":"Multimedia","icon":"applications-multimedia","categories":["Multimedia", "Player", "AudioVideo"]},
						{"name":"Office","icon":"applications-office","categories":["Office"]},
						{"name":"Science","icon":"applications-science","categories":["Science"]}
					]
					delegate: Row { id: filter
						required property var modelData

						padding: Globals.Controls.spacing
						spacing: Globals.Controls.spacing
						width: filters.availableWidth

						IconImage {
							implicitSize: 20
							source: Quickshell.iconPath(filter.modelData.icon)
						}

						Text {
							anchors.verticalCenter: parent.verticalCenter
							text: filter.modelData.name
							color: Globals.Colours.text
							font.pointSize: 10
						}
					}
					background: Rectangle {
						anchors.fill: parent
						topLeftRadius: Globals.Controls.radius
						bottomLeftRadius: Globals.Controls.radius
						color: Globals.Colours.base
					}
				}

				Ctrl.List { id: applications
					Layout.preferredWidth: 360
					Layout.fillHeight: true
					Layout.preferredHeight: col.height
					padding: Globals.Controls.padding
					leftPadding: 0
					mouse.enabled: !popout.isTransitioning
					onItemClicked: item => {
						item.modelData.execute();
						popout.isOpen = false;
					}
					model: {
						let list = [...DesktopEntries.applications.values] // list to search from
							.filter(a => !a.noDisplay) // remove entries that request to not be displayed
							.filter((obj, idx, item) => idx === item.findIndex(r => r.id === obj.id)) // dedupe list BUG
							.filter(a => { // filter by category
								const cs = filters.model[filters.view.currentIndex].categories;

								if (cs.length > 0) return a.categories.some(c => cs.includes(c));
								else return true;
							})

						return list
							.sort((a, b) => { // sort alphabetically
								return a.name.localeCompare(b.name);
							});
					}
					view.onModelChanged: applications.view.currentIndex = -1;
					delegate: RowLayout { id: application
						required property var modelData
						required property int index

						width: applications.availableWidth

						IconImage {
							Layout.leftMargin: Globals.Controls.spacing
							Layout.topMargin: Globals.Controls.spacing /2
							Layout.bottomMargin: Globals.Controls.spacing /2
							implicitSize: 32
							source: Quickshell.iconPath(application.modelData.name.toLowerCase(), true) || Quickshell.iconPath(application.modelData.icon, "application-x-generic")
						}

						ColumnLayout {
							Layout.rightMargin: Globals.Controls.spacing
							spacing: 0

							Text {
								Layout.fillWidth: true
								text: application.modelData.name
								elide: Text.ElideRight
								color: Globals.Colours.text
								font.pointSize: 10
							}

							Text {
								visible: application.modelData.comment
								Layout.fillWidth: true
								text: application.modelData.comment
								color: applications.view.currentIndex === application.index? Globals.Colours.mid :  Globals.Colours.light
								elide: Text.ElideRight
								font.pointSize: 6
								font.letterSpacing: 0.6
							}
						}
					}
					background: Rectangle { anchors.fill: parent; color: Globals.Colours.base; }
				}
			}
		}
	}
}
