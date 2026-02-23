# rdnashell
---
A simple and customizable shell, originally inspired by Waybar and with OOTB Niri support.
![screenshot](resources/Screenshot-01.png)

## Installation
---
### Dependencies
 - `quickshell-git` *must be the '-git' version*
 - `niri`
 - `brightnessctl`
### Arch
```bash
yay -S quickshell-git
git clone https://github.com/rdnamil/rdnashell .config/quickshell
qs
```

> [!note]
> Make a line in your WM config to startup quickshell on session start.
> > Ex. Niri: `spawn-at-startup "qs"`

## Configuration
---
### Shell config
Most configuration can be done in the `shell.qml` file. there you can specify what features and services you want. It might look something like this: 

```qml
import QtQuick
import Quickshell
import qs.components
import qs.widgets
import qs.services as Service

ShellRoot {
	// create a bar
	Bar {
		// populate the bar with widgets
		left: [Network {}, Bluetooth {}, Audio {}]
		centre: [NiriWorkspaces {}]
		right: [SystemTray {}, DateTime{}, NotificationTray {}]
	}
	// create notification toasts
	NotificationToasts {}
	
	// inititialize services/components
	Component.onCompleted: {
		Service.ShellUtils.init();
		Lockscreen.init();
		AppLauncher.init();
	}
}
```

### IPC
You can also use the IPC to integrate with your WM to create shortcuts. Run `qs ipc show` to see a comprehensive list of IPC calls. Make an IPC call with `qs ipc call <target> <function>`.

A short list of common calls: 
 - `qs ipc call launcher open`
 - `qs ipc call settings launch`
 - `qs ipc call notification toggleDnd`
 - `qs ipc call lockscreen lock`
