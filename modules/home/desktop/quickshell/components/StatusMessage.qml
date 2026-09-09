import QtQuick

Column {
    required property var themePalette
    property string title
    property string detail
    spacing: 4

    Text { text: title; color: themePalette.foreground; font.pixelSize: 13; font.weight: Font.DemiBold }
    Text { text: detail; color: themePalette.muted; font.pixelSize: 12; wrapMode: Text.WordWrap }
}
