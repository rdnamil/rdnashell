/*---------------------------
--- Sunsetr.qml by andrel ---
---------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	readonly property string day: `backend = "wayland"
	transition_mode = "static"
	static_temp = 6500
	static_gamma = 100
	`
	readonly property string night: `backend = "wayland"
	transition_mode = "static"
	static_temp = ${nightTemp}
	static_gamma = ${nightGamma}
	`
	readonly property bool enabled: (socket.preset?.current_temp !== 6500)
	readonly property string sunset: Qt.formatTime(root.offsetTime(new Date(Weather.forecast?.daily.sunset[0]), root.timezone), "hh:mm")
	readonly property string sunrise: Qt.formatTime(root.offsetTime(new Date(Weather.forecast?.daily.sunrise[1]), root.timezone), "hh:mm")

	property bool geo
	property string startTime
	property string endTime
	property int nightTemp
	property int nightGamma
	property string timezone

	function init(initNightTemp, initNightGamma, initGeo = true, initStartTime = "19:00", initEndTime = "7:00") {
		root.geo = initGeo;
		root.startTime = initStartTime;
		root.endTime = initEndTime;
		root.nightTemp = initNightTemp;
		root.nightGamma = initNightGamma;
		sunsetr.running = true;
	}

	function offsetTime(time, offset) {
		let sign = offset.startsWith('-')? -1 : 1;
		let hours = parseInt(offset.slice(1, 3));
		let min = parseInt(offset.slice(3, 5));
		let totalMs = (hours *3600000 +min *60000) *sign;

		return new Date(time.getTime() +totalMs);
	}

	function toggle() {
		if (root.enabled) root.disableNightlight();
		else root.enableNightlight();
	}

	function enableNightlight () {
		config.setData(root.night);
	}
	function disableNightlight () {
		config.setData(root.day);
	}

	FileView { id: config
		path: Qt.resolvedUrl("./sunsetr.toml")
	}

	Process {
		running: true
		command: ['date', '+%z']
		stdout: StdioCollector {
			onStreamFinished: root.timezone = text;
		}
	}

	Process { id: sunsetr
		// running: true
		command: ['sunsetr', '--config', `${Quickshell.shellDir}/services/`]
		onRunningChanged: if (running) console.log("Sunsetr: Sunsetr starting...");
		stdout: SplitParser {
			onRead: message => {
				if (message.includes("Successfully connected")) {
					console.log("Sunsetr: Sunsetr started successfully!");
					socket.connected = true;
				}
			}
		}
	}

	Socket { id: socket
		property var preset

		connected: false
		path: `${Quickshell.env("XDG_RUNTIME_DIR")}/sunsetr-events.sock`
		onConnectedChanged: {
			console.log("Sunsetr: " + (connected ? "New connection!" : "Connection dropped!"))

			if (!connected) connected = true;
		}
		parser: SplitParser {
			onRead: message => {
				// console.log(`read message from socket: ${message}`);
				socket.preset = JSON.parse(message);
			}
		}
	}

	SystemClock { id: clock
		readonly property string currentTime: Qt.formatTime(new Date(0,0,0,clock.hours,clock.minutes,0), "hh:mm")

		precision: SystemClock.Seconds
		onCurrentTimeChanged: {
			if (root.geo) {
				if (clock.currentTime === root.sunset) root.enableNightlight();
				else if (clock.currentTime === root.sunrise) root.disableNightlight ();
			} else {
				if (clock.currentTime === root.startTime) root.enableNightlight();
				else if (clock.currentTime === root.endTime) root.disableNightlight ();
			}
		}
	}
}
