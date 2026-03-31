pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	readonly property bool isConnecting: connectToNetwork.running

	property list<var> networks: []
	property list<var> saved: []
	property var status: ({})

	signal complete()

	function toggleRadio() {
		Quickshell.execDetached(['nmcli', 'r', 'w', root.status.radio? "off" : "on"]);
		getStatus.running = true;
	}

	function scan() {
		if (!scan.running) scan.running = true;
	}

	Process { // start nmcli manager
		running: true
		command: ['nmcli', 'm']
		stdout: SplitParser { onRead: if (!getStatus.running) getStatus.running = true; }
	}

	Process { id: getStatus
		command: ["sh", "-c", 'printf "%s%s\n" "$(nmcli -t -f TYPE,STATE,CONNECTION,IP4-CONNECTIVITY d | head -n1)" ":$(nmcli -t -f WIFI g)"']
		stdout: StdioCollector { onStreamFinished: {
			const parts = text.split(':');

			root.status = {
				type: parts[0],
				state: parts[1],
				connection: parts[2],
				connectivity: parts[3],
				radio: parts[4].trim() === "enabled"
			};
		}}
	}

	Process { id: scan
		running: true
		command: ['nmcli', 'd', 'w', 'r']
		stdout: StdioCollector { onStreamFinished: getNetworks.running = true; }
	}

	Process { id: getNetworks
		command: ['nmcli', '-t', '-f', 'SSID,SIGNAL,SECURITY', 'd', 'w']
		stdout: StdioCollector { onStreamFinished: {
			const nets = text
			.trim()
			.split('\n');

			root.networks = [];

			nets.forEach(n => {
				const parts = n.split(':');
				const net = {
					ssid: parts[0],
					strength: parts[1],
					security: parts[2].trim(),
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
}
