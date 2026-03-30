pragma Singleton

import Quickshell
import Quickshell.Io

Singleton { id: root
	readonly property bool isPowered: root.adapters.some(a => a.powered) ?? false
	readonly property bool isScanning: root.adapters.some(a => a.discovering) ?? false
	readonly property bool isPaired: root.devices.some(d => d.connected) ?? false

	property list<var> adapters: []
	property list<var> devices: []

	function toggleAdapter() { Quickshell.execDetached(['bluetoothctl', 'power', root.isPowered? 'off' : 'on']); }

	function scan(seconds = 5) {
		scan.timeout = seconds;

		if (!scan.running) scan.running = true;
	}

	Process { id: bluetooth
		running: true
		command: ['bluetoothctl']
		stdout: SplitParser { onRead: (text) => {
			const match = text
				.replace(/\u001b\[[0-9;]*[a-zA-Z]/g, "")
				.replace(/\r/g, "")
				.trim()
				.match(/\[(\w+)\]\s+(\w+)\s+([0-9A-Fa-f:]{17})\s+(.+)$/m);

			if (match) {
				const [, type, kind, address, name] = match;

				// console.log(`Bluetooth: ${type} ${address} ${name}`);

				if (kind === "Device") switch (type) {
					case "NEW":
					case "CHG":
						getDeviceInfo.devices.push(address);
						break;
					case "DEL":
						root.devices.splice(root.devices.findIndex(d => d.address === address), 1);
						break;
				} else if (kind === "Controller") getAdapters.running = true;
			}
		}}
	}

	Process { id: scan
		property int timeout

		command: ['bluetoothctl', '-t', timeout, 'scan', 'on']
	}

	Process { id: getAdapters
		running: true
		command: ['bluetoothctl', 'show']
		stdout: StdioCollector { onStreamFinished: {
			function parseController(chunk) {
				const ctrl = {};

				const header = chunk.match(/^Controller\s+([0-9A-Fa-f:]{17})\s+\((\w+)\)/m);
				if (header) ctrl.address = header[1];

				const fieldMap = {
					Name: "name",
					Alias: "alias",
					Class: "class",
					Manufacturer: "manufacturer",
					Version: "version",
					Powered: "powered",
					PowerState: "powerState",
					Discoverable: "discoverable",
					DiscoverableTimeout: "discoverableTimeout",
					Pairable: "pairable",
					Modalias: "modalias",
					Discovering: "discovering",
				};

				for (const [label, key] of Object.entries(fieldMap)) {
					const match = chunk.match(new RegExp(`${label}:\\s+(.+?)(?=\\s{2,}|$)`, "m"));

					if (match) {
						const raw = match[1].trim();

						if (raw === "yes") ctrl[key] = true;
						else if (raw === "no") ctrl[key] = false;
						else ctrl[key] = raw;
					}
				}

				const idx = root.adapters.findIndex(a => a.address === ctrl.address);

				if (idx !== -1) root.adapters.splice(idx, 1, ctrl);
				else root.adapters.push(ctrl);
			}

			const headers = [];
			const headerRegex = /Controller\s+[0-9A-Fa-f:]{17}\s+\(\w+\)/g;
			let header;

			while ((header = headerRegex.exec(text)) !== null) headers.push(header);

			headers.forEach((h, i) => { parseController(text.slice(h.index, h[i +1]?.index ?? text.length)); });
		}}
	}

	Process { id: getDevices
		running: true
		command: ['bluetoothctl', 'devices']
		stdout: StdioCollector { onStreamFinished: {
			const devs = text.trim()?.split('\n') || [];

			devs.forEach(d => {
				const addr = d.match(/^Device\s+([0-9A-F:]+)\s+(.+)$/m);

				if (addr) getDeviceInfo.devices.push(addr[1]);
			});
		}}
	}

	Process { id: getDeviceInfo
		property list<string> devices: []

		function startProc() {
			getDeviceInfo.command = getDeviceInfo.command = ['bluetoothctl', 'info', devices[0]];
			getDeviceInfo.running = true
		}

		onDevicesChanged: if (!running && devices.length > 0) startProc();
		onRunningChanged: if (!running && devices.length > 0) startProc();
		stdout: StdioCollector { onStreamFinished: {
			const dev = {
				connect: function() {
					Quickshell.execDetached(['bluetoothctl', 'connect', this.address]);
				},
				disconnect: function() {
					Quickshell.execDetached(['bluetoothctl', 'disconnect', this.address]);
				}
			};

			// get mac address
			const header = text.match(/^Device\s+([0-9A-F:]+)\s+\((\w+)\)/m);
			if (header) dev.address = header[1];

			// parse key:value pairs
			const fieldMap = {
				Name: "name",
				Alias: "alias",
				Class: "class",
				Icon: "icon",
				Paired: "paired",
				Bonded: "bonded",
				Trusted: "trusted",
				Blocked: "blocked",
				Connected: "connected",
				WakeAllowed: "wakeAllowed",
				LegacyPairing: "legacyPairing",
				CablePairing: "cablePairing",
				Modalias: "modalias",
			};

			for (const [label, key] of Object.entries(fieldMap)) {
				const match = text.match(new RegExp(`^\\s+${label}:\\s+(.+)$`, "m"));

				if (match) {
					const raw = match[1].trim();

					if (raw === "yes") dev[key] = true;
					else if (raw === "no") dev[key] = false;
					else dev[key] = raw;
				}
			}

			const idx = root.devices.findIndex(d => d.address === dev.address);

			if (idx !== -1) root.devices.splice(idx, 1, dev);
			else root.devices.push(dev);

			getDeviceInfo.devices.splice(0, 1);
		}}
	}
}
