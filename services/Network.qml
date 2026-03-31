pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	readonly property bool isConnecting: connectToNetwork.running
	readonly property QtObject radio: QtObject {
		property bool present: false
		property bool powered: false
	}

	property list<var> networks: []
	property list<var> saved: []
	property var status: ({})

	signal complete()

	function toggleRadio() { getRadio.exec(['nmcli', 'r', 'w', root.radio.powered? "off" : "on"]); }

	function scan() {
		if (!scan.running) scan.running = true;
		getRadio.running = true;
	}

	Process { // start nmcli manager
		running: true
		command: ['nmcli', 'm']
		stdout: SplitParser { onRead: if (!getStatus.running) getStatus.running = true; }
	}

	Process { id: getRadio
		running: true
		command: ['nmcli', '-t', '-f', 'WIFI', 'g']
		stdout: StdioCollector { onStreamFinished: {
			if (text.trim()) root.radio.powered = text.trim() === "enabled";
			else getRadio.exec(['nmcli', '-t', '-f', 'WIFI', 'g']);
		}}
	}

	Process { id: getStatus
		command: ['nmcli', '-t', '-f', 'TYPE,STATE,CONNECTION,IP4-CONNECTIVITY', 'd']
		stdout: StdioCollector { onStreamFinished: {
			const devices = text
				.trim()
				.split('\n');

			let stats = [];
			devices.forEach((d, i) => {
				const parts = devices[0].split(':');

				stats.push({
					type: parts[0],
					state: parts[1],
					connection: parts[2],
					connectivity: parts[3]
				});
			});

			root.status = stats[0];
			root.radio.present = stats.some(s => s.type == "wireless");
		}}
	}

	Process { id: scan
		running: true
		command: ['nmcli', 'd', 'w', 'r']
		onExited: code => { if (code === 0) getNetworks.running = true; }
	}

	Process { id: getNetworks
		command: ['nmcli', '-t', '-f', 'SSID,SIGNAL,SECURITY', 'd', 'w']
		stdout: StdioCollector { onStreamFinished: {
			const nets = text
			.trim()
			.split('\n');

			nets.forEach(n => {
				const parts = n.split(':');
				const net = {
					ssid: parts[0],
					strength: parts[1],
					security: parts[2]?.trim() || undefined,
					connect: function() {
						if (!this.security || root.saved.includes(this.ssid))
							connectToNetwork.exec(['nmcli', 'd', 'w', 'c', this.ssid]);
						else {
							PopoutManager.whosOpen = null;
							connectToNetwork.exec(['sh', '-c', `nmcli d w c "${this.ssid}" password "$(yad --entry --hide-text --licon=object-locked)"`]);
						}
					},
					disconnect: function() {
						Quickshell.execDetached(['nmcli', 'c', 'down', this.ssid]);
					}
				}

				const idx = root.networks.findIndex(n => n.ssid === net.ssid);
				if (idx === -1) root.networks.push(net);
				else if (net.strength > root.networks[idx].strength) root.networks.splice(idx, 1, net);
			});
		}}
	}

	Process { id: getSavedNetworks
		running: true
		command: ['nmcli', '-t', '-f', 'NAME', 'c', 's']
		stdout: StdioCollector { onStreamFinished: {
			root.saved = text
				.trim()
				.split('\n');
		}}
	}

	Process { id: connectToNetwork
		onExited: code => {
			if (code == 4) {
				PopoutManager.whosOpen = null;
				connectToNetwork.exec(['sh', '-c', `nmcli d w c "${this.ssid}" password "$(yad --entry --hide-text --licon=object-locked)"`]);
			} else root.complete();
		}
	}

	Process { id: share
		command: ['nmcli', 'd', 'w', 's']
	}

	// scan every 5min
	Timer {
		interval: 3e5
		onTriggered: if (!scan.running) scan.running = true;
	}
}
