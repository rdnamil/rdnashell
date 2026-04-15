pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	property list<var> updates: []
	property list<string> updateCommand: ['yay']
	property bool lock

	function checkUpdates() { if (!lock) {
		root.lock = true;
		timer.restart();
		root.updates = [];
		getUpdates.running = true;
		getAurUpdates.running = true;
	}}

	function update() { if (!lock) {
		updateProc.exec(['ghostty', '-e', root.updateCommand]);
	}}

	FileView { id: infoView
		path: Qt.resolvedUrl("info.json")
		onLoaded: root.checkUpdates();
		onLoadFailed: (error) => {
			if (error === FileViewError.FileNotFound) getInfo.running = true;
		}

		JsonAdapter {
			property list<var> info: []
		}
	}

	Process { id: getInfo
		// running: true
		command: ['pacman', '-Si']
		stdout: StdioCollector { onStreamFinished: {
			infoView.adapter.info = text
				.split(/\n\s*\n/)
				.map(e => {
					const pkg = {};

					e.split('\n').forEach(l => {
						const match = l.match(/^([^:]+?)\s*:\s*(.*)$/);
						if (match && (match[1].trim() == "Name" || match[1].trim() == "Repository")) {
							// const key = match[1].trim();
							// const value = match[2].trim();
							pkg[match[1].trim()] = match[2].trim();
						}
					});

					return pkg;
				});

			infoView.writeAdapter();
		}}
	}

	Process { id: getUpdates
		command: ['checkupdates']
		onExited: if (!getAurUpdates.running) root.lock = false;
		stdout: StdioCollector { onStreamFinished: {
			root.updates.push(...text.trim()
				.split('\n')
				.map(l => {
					const u = l.split(' ');
					return {
						"package": u[0],
						"repo": infoView.adapter.info.find(p => p.Name === u[0])?.Repository || '',
						"current": u[1],
						"new": u[3]
					}
				}));
		}}
	}

	Process { id: getAurUpdates
		command: [root.updateCommand, '-Qua']
		onExited: if (!getUpdates.running) root.lock = false;
		stdout: StdioCollector { onStreamFinished: {
			root.updates.push(...text.trim()
				.split('\n')
				.map(l => {
					const u = l.split(' ');
					return {
						"package": u[0],
						"repo": "aur",
						"current": u[1],
						"new": u[3]
					}
				}));
		}}
	}

	Process { id: updateProc
		onStarted: root.lock = true;
		onExited: (code, status) => {
			root.lock = false;

			if (code !== 0) {
				root.updates = [];
				getInfo.running = true;
			}
		}
	}

	Timer { id: timer
		interval: 36e5
		repeat: true
		onTriggered: root.checkUpdates();
	}
}
