import Quickshell
import Quickshell.Io
import QtQuick
import "state"
import "services"
import "theme"
import "windows"

Scope {
    id: root

    Palette { id: shellPalette }
    Metrics { id: shellMetrics }
    OverlayState { id: shellOverlayState }
    OsdState { id: shellOsdState }
    AccessibilityState { id: shellAccessibilityState }
    AudioService { id: shellAudioService }
    BrightnessService { id: shellBrightnessService }
    NetworkService { id: shellNetworkService }
    BluetoothService { id: shellBluetoothService }

    IpcHandler {
        target: "shell"

        function toggleControlCentre(): void {
            shellOverlayState.toggle("gallery")
        }

        function openControlCentre(): void {
            shellOverlayState.activeOverlay = "gallery"
        }

        function isControlCentreOpen(): bool {
            return shellOverlayState.activeOverlay === "gallery"
        }

        function closeControlCentre(): void {
            shellOverlayState.close()
        }

        function showVolumeOsd(): void {
            shellOsdState.show("volume")
        }

        function showBrightnessOsd(): void {
            shellBrightnessService.refresh()
            shellOsdState.show("brightness")
        }

        function toggleLauncher(): void {
            console.info("Launcher is not available during Phase 2")
        }
    }

    Variants {
        model: Quickshell.screens

        ComponentGallery {
            required property var modelData
            screenModel: modelData
            themePalette: shellPalette
            metrics: shellMetrics
            overlayState: shellOverlayState
            accessibilityState: shellAccessibilityState
            audioService: shellAudioService
            brightnessService: shellBrightnessService
            networkService: shellNetworkService
            bluetoothService: shellBluetoothService
        }
    }

    Variants {
        model: Quickshell.screens

        OnScreenDisplay {
            required property var modelData
            screenModel: modelData
            themePalette: shellPalette
            metrics: shellMetrics
            accessibilityState: shellAccessibilityState
            osdState: shellOsdState
            audioService: shellAudioService
            brightnessService: shellBrightnessService
        }
    }
}
