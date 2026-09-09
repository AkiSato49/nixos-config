import QtQuick
import QtQuick.Controls

Control {
    id: control
    required property var themePalette
    property var choices: []
    property int currentIndex: 0
    signal selected(int index)

    implicitHeight: 40
    Accessible.name: "Choice"

    contentItem: Row {
        spacing: 2
        Repeater {
            model: control.choices
            delegate: Button {
                text: modelData
                Accessible.name: modelData
                Accessible.role: Accessible.Button
                onClicked: control.selected(index)
                background: Rectangle {
                    radius: 8
                    color: index === control.currentIndex ? control.themePalette.accentSoft : "transparent"
                    border.width: control.activeFocus ? 2 : 0
                    border.color: control.themePalette.focus
                }
                contentItem: Text {
                    text: parent.text
                    color: control.themePalette.foreground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                }
            }
        }
    }
}
