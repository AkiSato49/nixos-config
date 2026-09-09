import QtQuick
import QtQuick.Controls

Button {
    id: control
    required property var themePalette
    property string title
    property string detail
    property bool connected: false

    implicitHeight: 52
    Accessible.name: title + ": " + detail
    Accessible.role: Accessible.Button

    contentItem: Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        Rectangle {
            width: 8; height: 8; radius: 4
            anchors.verticalCenter: parent.verticalCenter
            color: control.connected ? control.themePalette.positive : control.themePalette.muted
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 32
            Text { text: control.title; color: control.themePalette.foreground; font.pixelSize: 13 }
            Text { text: control.detail; color: control.themePalette.muted; font.pixelSize: 11 }
        }
    }
    background: Rectangle {
        color: control.hovered ? control.themePalette.surfaceHover : "transparent"
        radius: 8
        border.width: control.activeFocus ? 2 : 0
        border.color: control.themePalette.focus
    }
}
