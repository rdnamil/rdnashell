/*-------------------------------
--- LockContext.qml by andrel ---
-------------------------------*/

import Quickshell
import Quickshell.Services.Pam

Scope { id: root
	readonly property bool unlockInProgress: pam.unlockInProgress

	property bool showFailure

	signal unlocked()
	signal failed()

	function tryUnlock(passwd) {
		if (passwd === "") return;

		pam.unlockInProgress = true;
		pam.passwd = passwd;
		pam.start();
	}

	PamContext { id: pam
		property string passwd
		property bool unlockInProgress

		onPamMessage: if (this.responseRequired) this.respond(pam.passwd);
		onCompleted: result => {
			if (result == PamResult.Success) root.unlocked();
			else {
				root.failed();
				root.showFailure = true;
			}

			pam.unlockInProgress = false;
		}
	}
}
