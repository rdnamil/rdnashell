import QtQuick
import QtQuick.Layouts
import "../../globals.js" as Globals

ColumnLayout { id: root
	Rectangle {
		Layout.margins: Globals.Controls.padding
		Layout.fillWidth: true
		Layout.preferredHeight: width *(9 /16)
	}
}
