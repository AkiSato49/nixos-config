import QtQuick
import QtQuick.Controls

Slider {
    id: control
    required property var themePalette
    property string accessibleName

    implicitHeight: 28
    from: 0
    to: 100
    Accessible.name: accessibleName
    Accessible.role: Accessible.Slider

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 8
        radius: 4
        color: control.themePalette.track

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: control.themePalette.accent
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 18
        height: 18
        radius: 9
        color: control.themePalette.background
        border.width: control.activeFocus ? 3 : 2
        border.color: control.activeFocus ? control.themePalette.focus : control.themePalette.accent
    }
}
