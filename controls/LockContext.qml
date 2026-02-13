/*-------------------------------
--- LockContext.qml by andrel ---
-------------------------------*/

import Quickshell
import Quickshell.Services.Pam

Scope { id: root
	signal unlocked()
	signal failed()

	property string passwd
	property bool unlockInProgress
	property bool showFailure

	function tryUnlock() {
		if (passwd === "") return;

		root.unlockInProgress = true;
		pam.start();
	}

	PamContext { id: pam
		onPamMessage: if (this.responseRequired) this.respond(root.passwd);
		onCompleted: result => {
			if (result == PamResult.Success) root.unlocked();
			else root.failed();

			root.unlockInProgress = false;
		}
	}
}
