import QtQuick
import QtQuick.Controls

Button {
    id: control
    required property var themePalette
    property url iconSource
    property string accessibleName

    implicitWidth: 40
    implicitHeight: 40
    Accessible.name: accessibleName
    Accessible.role: Accessible.Button

    contentItem: Image {
        source: control.iconSource
        sourceSize.width: 20
        sourceSize.height: 20
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
    }

    background: Rectangle {
        radius: 8
        color: control.down ? control.themePalette.surfacePressed
            : control.hovered ? control.themePalette.surfaceHover : "transparent"
        border.width: control.activeFocus ? 2 : 0
        border.color: control.themePalette.focus
    }
}
