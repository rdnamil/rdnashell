pragma Singleton

import Quickshell
import Quickshell.Io

Singleton { id: root
	property list<var> wallpapers: []

	function getWallpaper() { if (!getWallpaper.running) getWallpaper.running = true; }
	function setWallpaper(path, transition = "grow", output = "") { applyWallpaper.exec(['swww', 'img', path, '--transition-type', transition, '--transition-fps', '60', '--outputs', output]); }

	Process { id: getWallpaper
		running: true
		command: ['swww', 'query']
		stdout: StdioCollector {
			onStreamFinished: {
				root.wallpapers = text
					.trim()
					.split('\n')
					.map(w => {
						const parts = w.match(/:\s*(\S+):\s*(\d+x\d+),\s*scale:\s*(\d+),\s*currently displaying:\s*(\w+):\s*(.+)/);

						return {
							display: parts[1],
							resolution: parts[2],
							scale: Number(parts[3]),
							type: parts[4],
							path: parts[5].trim()
						};
					});
			}
		}
	}

	Process { id: applyWallpaper
		stdout: StdioCollector { onStreamFinished: getWallpaper.running = true; }
	}


	IpcHandler {
		target: "swww"

		function applyWallpaper(path: string): void { root.setWallpaper(path); }
	}
}
