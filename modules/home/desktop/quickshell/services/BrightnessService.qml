import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property real value: 0
    property bool available: true
    property string error: ""
    property real pendingValue: 0

    function parse(text: string): void {
        const fields = text.trim().split(",")
        if (fields.length < 4) {
            available = false
            error = "Brightness device unavailable"
            return
        }
        const percent = Number(fields[3].replace("%", ""))
        if (Number.isFinite(percent)) {
            value = percent
            available = true
            if (error !== "Brightness write failed") error = ""
        } else {
            available = false
            error = "Brightness device unavailable"
        }
    }

    function refresh(): void {
        if (!reader.running) reader.running = true
    }

    function setValue(next: real): void {
        pendingValue = Math.max(0, Math.min(100, next))
        error = ""
        writeDebounce.restart()
    }

    Process {
        id: reader
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.available = false
                root.error = "Brightness device unavailable"
            }
        }
    }
    Process {
        id: writer
        command: ["brightnessctl", "set", Math.round(root.pendingValue) + "%"]
        onExited: exitCode => {
            if (exitCode !== 0) root.error = "Brightness write failed"
            root.refresh()
        }
    }
    Timer {
        id: writeDebounce
        interval: 75
        onTriggered: if (!writer.running) writer.running = true
    }
    Component.onCompleted: refresh()
}
