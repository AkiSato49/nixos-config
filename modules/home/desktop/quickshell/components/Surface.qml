import QtQuick

Rectangle {
    required property var themePalette
    property int surfaceRadius: 14

    radius: surfaceRadius
    color: themePalette.background
    border.width: 1
    border.color: themePalette.border
}
