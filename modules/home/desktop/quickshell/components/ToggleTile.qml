import QtQuick
import QtQuick.Controls

Button {
    id: control
    required property var themePalette
    property url iconSource
    property string title
    property string detail
    property bool active: false

    implicitWidth: 220
    implicitHeight: 76
    Accessible.name: title + ": " + detail
    Accessible.role: Accessible.Button

    contentItem: Row {
        spacing: 12
        anchors.fill: parent
        anchors.margins: 12

        Image {
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter
            source: control.iconSource
            sourceSize.width: 24
            sourceSize.height: 24
        }
        Column {
            width: parent.width - 48
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { text: control.title; color: control.themePalette.foreground; font.pixelSize: 14; font.weight: Font.DemiBold }
            Text { text: control.detail; color: control.themePalette.muted; font.pixelSize: 12; elide: Text.ElideRight; width: parent.width }
        }
    }

    background: Rectangle {
        radius: 14
        color: control.active ? control.themePalette.accentSoft : control.themePalette.surfaceRaised
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? control.themePalette.focus : control.themePalette.border
    }
}
