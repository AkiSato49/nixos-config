import QtQuick

QtObject {
    // Windows select their QsScreen directly. Phase 2 adds focused-screen
    // tracking through Hyprland IPC without fixed connector coordinates.
    property var selectedScreen: null
}
