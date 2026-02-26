pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components

Singleton { id: root
	function init(timemout) { monitor.timeout = timemout; }

	IdleMonitor { id: monitor
		timeout: 300
		onIsIdleChanged: Lockscreen.lock(true);
	}
}
