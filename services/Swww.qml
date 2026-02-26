pragma Singleton

import Quickshell
import Quickshell.Io

Singleton { id: root
	property list<var> wallpapers: []

	function getWallpaper() { if (!getWallpaper.running) getWallpaper.running = true; }
	function setWallpaper(path) { applyWallpaper.exec(['swww', 'img', path]); }

	Process { id: getWallpaper
		running: true
		command: ['swww', 'query']
		stdout: StdioCollector {
			onStreamFinished: {
				var ws = text.trim().split('\n');

				root.wallpapers = [];

				for (let w of ws) {
					const parts = w.match(/^:\s*(\S+):\s*([^,]+),\s*scale:\s*(\d+),\s*currently displaying:\s*(\w+):\s*(.+)$/);

					if (!parts) continue;

					root.wallpapers.push({
						display: parts[1],
						resolution: parts[2],
						scale: parts[3],
						type: parts[4],
						path: parts[5]
					});
				}
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
