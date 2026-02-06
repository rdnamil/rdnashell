/*-------------------------------
--- AppLauncher.qml by andrel ---
-------------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import qs.controls as Ctrl
import qs.styles as Style
import "../globals.js" as Globals
import "./fuse.js" as FuseLib

Singleton { id: root
	function init() {
		loader.active = false;
	}

	function close() {
		loader.active = false;
		fileview.writeAdapter();
	}

	// save app stats
	FileView { id: fileview
		path: Qt.resolvedUrl("./apps.json")

		JsonAdapter { id: jsonAdapter
			property list<var> applications
		}
	}

	Loader { id: loader
		active: true
		sourceComponent: PanelWindow {
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			exclusiveZone: -1
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.namespace: "qs:launcher"
			color: Globals.Settings.debug? "#40ff0000" : "transparent"
			implicitWidth: layout.width +60
 			implicitHeight: layout.height +60

 			RectangularShadow {
				anchors.fill: layout
				radius: Globals.Controls.radius
				blur: 30
				opacity: 0.4
			}

			MouseArea {
				anchors.fill: parent
				onClicked: root.close(); // close the launcher on outside click
			}

			Style.PageLayout { id: layout
				x: parent.width /2 -width /2
				y: parent.height *(2 /5) -header.height /2
				header: Item {
					width: list.width
					height: textInputLayout.height +Globals.Controls.padding *2

					RectangularShadow {
						anchors.fill: textInputLayout
						radius: Globals.Controls.radius *(3 /4)
						opacity: 0.4
					}

					Rectangle {
						anchors.fill: textInputLayout
						radius: Globals.Controls.radius *(3 /4)
						color: Globals.Colours.dark
					}

					RowLayout { id: textInputLayout
						anchors.centerIn: parent
						width: parent.width -Globals.Controls.padding *2

						IconImage {
							Layout.margins: Globals.Controls.spacing
							implicitSize: Globals.Controls.iconSize
							source: Quickshell.iconPath("search")
						}

						TextInput { id: textInput
							Layout.fillWidth: true
							focus: true
							color: Globals.Colours.text
							font.pointSize: 10
							onTextEdited: list.view.currentIndex = 0;
							onAccepted: list.itemClicked(list.view.currentItem, null);
							Keys.onPressed: (event) => {
								switch (event.key) {
									case Qt.Key_Escape:
										root.close();
										break;
									case Qt.Key_Up:
										list.view.decrementCurrentIndex();
										break;
									case Qt.Key_Tab:
									case Qt.Key_Down:
										list.view.incrementCurrentIndex();
										break;
								}
							}

							// placeholder text
							Text {
								visible: !parent.text
								leftPadding: Globals.Controls.spacing
								text: "start typing to search..."
								color: Globals.Colours.mid
								font.pointSize: 10
								font.weight: 300
								font.italic: true
							}
						}
					}
				}
				body: Ctrl.List { id: list
					// show up to 10 dekstop entries max
					height: Math.min(view.contentHeight, (32 +Globals.Controls.spacing *2) *10 -Globals.Controls.spacing) +Globals.Controls.padding
					onItemClicked: item => {
						// add an etry if none exist
						if (!jsonAdapter.applications.find(a => a.id === item.modelData.id)) {
							jsonAdapter.applications.push({
								"id": item.modelData.id,
								"count": 1,
								"lastOpened": Date.now()
							});
							// console.log("Startmenu: Added entry.");
							// update entry if there's already one
						} else {
							jsonAdapter.applications.find(a => a.id === item.modelData.id).count += 1;
							jsonAdapter.applications.find(a => a.id === item.modelData.id).lastOpened = Date.now();
							// console.log("Startmenu: Updated entry.");
						}
						item.modelData.execute();
						root.close();
					}
					model: {
						let list = [...DesktopEntries.applications.values] // list to search from
						.filter(a => !a.noDisplay) // remove entries that request to not be displayed
						.filter((obj, idx, item) => idx === item.findIndex(r => r.id === obj.id)) // dedupe list BUG

						const countMin = Math.min(...jsonAdapter.applications.filter(a => a.count).map(a => a.count));
						const countNormalDevisor = Math.max(...jsonAdapter.applications.filter(a => a.count).map(a => a.count)) -countMin;
						const ageMin = Math.min(...jsonAdapter.applications.filter(a => a.lastOpened).map(a => a.lastOpened)) -Date.now();
						const ageNormalDevisor = Math.max(...jsonAdapter.applications.filter(a => a.lastOpened).map(a => a.lastOpened)) -Date.now() -ageMin
						const recencyWeight = 0.4;

						function calcRelevance(app, now = Date.now()) {
							const countNormal = (app.count -countMin) /countNormalDevisor;
							const ageNormal = (app.lastOpened -now -ageMin) /ageNormalDevisor;
							return recencyWeight *ageNormal +(1 -recencyWeight) *countNormal;
						}

						const relevanceMap = new Map(
							jsonAdapter.applications.map(app => [app.id, calcRelevance(app)])
						);

						if (textInput.text) {
							const options = {
								keys: ["id", "name", "genericName", "keywords"],
								threshold: 0.4,
								includeScore: true,
								shouldSort: true
							};
							const fuse = new Fuse(list, options);

							return fuse.search(textInput.text)
							.sort((a, b) => { // return search results sorted based on score and relevance
								const scoreWeight = 0.6;

								const a_App = jsonAdapter.applications.find(app => app.id === a.item.id);
								const b_App = jsonAdapter.applications.find(app => app.id === b.item.id);

								function calcWeightedMatch(app, score, now = Date.now()) {
									const relevance = calcRelevance(app);
									return scoreWeight *(1 -score) +(1 -scoreWeight) *relevance;
								}

								const a_weightedMatch = a_App? calcWeightedMatch(a_App, a.score) : null;
								const b_weightedMatch = b_App? calcWeightedMatch(b_App, b.score) : null;

								if (a_weightedMatch && b_weightedMatch) return b_weightedMatch -a_weightedMatch;
								else if (a_weightedMatch) return -1;
								else if (b_weightedMatch) return 1;
								else return a.score -b.score;
							})
							.map(r => r.item);
						} else return list
							.sort((a, b) => {
								const a_App = jsonAdapter.applications.find(app => app.id === a.id);
								const b_App = jsonAdapter.applications.find(app => app.id === b.id);

								const a_Fav = a_App? a_App.isFavourite : null;
								const b_Fav = b_App? b_App.isFavourite : null;

								// move favourites to top of the list
								if (a_Fav && b_Fav) return b_Fav -a_Fav;
								else if (a_Fav) return -1;
								else if (b_Fav) return 1;

								// sort by relevance
								const a_Relevance = relevanceMap.get(a.id);
								const b_Relevance = relevanceMap.get(b.id);

								if (a_Relevance && b_Relevance) { return b_Relevance -a_Relevance; console.log("debug") }
								else if (a_Relevance) return -1;
								else if (b_Relevance) return 1;

								// sort alphabetically
								return a.name.localeCompare(b.name);
							});
					}
					delegate: Item { id: delegate
						required property var modelData
						required property int index

						width: list.availableWidth
						height: appLayout.height +Globals.Controls.spacing

						RowLayout { id: appLayout
							anchors.centerIn: parent
							width: parent.width -Globals.Controls.spacing *2

							IconImage {
								implicitSize: 32
								source: Quickshell.iconPath(delegate.modelData.icon, false)
							}

							ColumnLayout {
								spacing: 0

								Text {
									Layout.fillWidth: true
									text: delegate.modelData.name
									color: Globals.Colours.text
									font.pointSize: 10
								}

								Text {
									visible: delegate.modelData.comment
									Layout.fillWidth: true
									text: delegate.modelData.comment
									color: list.view.currentIndex === delegate.index? Globals.Colours.mid :  Globals.Colours.light
									elide: Text.ElideRight
									font.pointSize: 6
									font.letterSpacing: 0.6
								}
							}
						}
					}
				}
			}
		}
	}

	IpcHandler {
		target: "launcher"

		function open(): void { loader.active = true; }
	}
}
