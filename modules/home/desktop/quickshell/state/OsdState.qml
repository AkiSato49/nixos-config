import QtQuick

QtObject {
    property string kind: ""
    property bool visible: false

    function show(nextKind: string): void {
        kind = nextKind
        visible = true
        hideTimer.restart()
    }

    property Timer hideTimer: Timer {
        interval: 1800
        onTriggered: parent.visible = false
    }
}
