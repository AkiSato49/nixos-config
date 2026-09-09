import QtQuick

QtObject {
    property string activeOverlay: ""

    function toggle(name: string): void {
        activeOverlay = activeOverlay === name ? "" : name
    }

    function close(): void {
        activeOverlay = ""
    }
}
