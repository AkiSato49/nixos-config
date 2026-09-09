import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Scope {
    id: root

    readonly property var nodes: Pipewire.nodes
    readonly property var output: Pipewire.defaultAudioSink
    readonly property var input: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.output, root.input]
    }
    readonly property bool outputAvailable: output !== null && output.audio !== null
    readonly property bool inputAvailable: input !== null && input.audio !== null
    readonly property real outputVolume: outputAvailable ? output.audio.volume : 0
    readonly property real inputVolume: inputAvailable ? input.audio.volume : 0
    readonly property bool outputMuted: outputAvailable && output.audio.muted
    readonly property bool inputMuted: inputAvailable && input.audio.muted

    function isOutputDevice(node: var): bool {
        return node !== null && node.audio !== null && node.isSink && !node.isStream
    }
    function isInputDevice(node: var): bool {
        return node !== null && node.audio !== null && !node.isSink && !node.isStream
    }
    function selectOutput(node: var): void {
        if (isOutputDevice(node)) Pipewire.preferredDefaultAudioSink = node
    }
    function selectInput(node: var): void {
        if (isInputDevice(node)) Pipewire.preferredDefaultAudioSource = node
    }
    function setOutputVolume(value: real): void {
        if (outputAvailable) output.audio.volume = Math.max(0, Math.min(1.5, value))
    }
    function setInputVolume(value: real): void {
        if (inputAvailable) input.audio.volume = Math.max(0, Math.min(1.5, value))
    }
    function toggleOutputMute(): void {
        if (outputAvailable) output.audio.muted = !output.audio.muted
    }
    function toggleInputMute(): void {
        if (inputAvailable) input.audio.muted = !input.audio.muted
    }
}
