import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../components"

PanelWindow {
    id: window
    required property var screenModel
    required property var themePalette
    required property var metrics
    required property var accessibilityState
    required property var osdState
    required property var audioService
    required property var brightnessService

    screen: screenModel
    // Keep OSD on output containing active client; no duplicate alerts on docks.
    // Compare connector names: monitorFor() can return a separate QML wrapper.
    readonly property var targetMonitor: Hyprland.activeToplevel && Hyprland.activeToplevel.monitor
        ? Hyprland.activeToplevel.monitor
        : Hyprland.focusedMonitor
    visible: osdState.visible && (!targetMonitor || screenModel.name === targetMonitor.name)
    color: "transparent"
    implicitWidth: 360
    implicitHeight: 104

    anchors {
        right: true
        bottom: true
    }
    margins {
        right: metrics.space8
        bottom: metrics.space8
    }

    Surface {
        anchors.fill: parent
        themePalette: window.themePalette
        surfaceRadius: window.metrics.radiusMedium

        Column {
            anchors.fill: parent
            anchors.margins: window.metrics.space4
            spacing: window.metrics.space3

            Text {
                width: parent.width
                color: window.themePalette.foreground
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: window.title
            }

            Text {
                visible: window.unavailable
                width: parent.width
                color: window.themePalette.danger
                font.pixelSize: 12
                text: window.errorText
            }

            Rectangle {
                visible: !window.unavailable
                width: parent.width
                height: 8
                radius: 4
                color: window.themePalette.track

                Rectangle {
                    width: parent.width * window.level / window.maximum
                    height: parent.height
                    radius: parent.radius
                    color: window.themePalette.accent
                }
            }
        }
    }

    readonly property bool isBrightness: osdState.kind === "brightness"
    readonly property bool unavailable: isBrightness
        ? !brightnessService.available
        : !audioService.outputAvailable
    readonly property real maximum: isBrightness ? 100 : 150
    readonly property real level: unavailable ? 0 : (isBrightness
        ? brightnessService.value
        : audioService.outputVolume * 100)
    readonly property string title: unavailable ? (isBrightness ? "Brightness unavailable" : "Output unavailable")
        : isBrightness ? "Brightness · " + Math.round(level) + "%"
        : audioService.outputMuted ? "Volume muted · " + Math.round(level) + "%"
        : "Volume · " + Math.round(level) + "%"
    readonly property string errorText: isBrightness ? brightnessService.error : "No default audio output device"
}
