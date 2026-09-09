import Quickshell
import QtQuick
import QtQuick.Controls
import "../components"

PanelWindow {
    id: window
    required property var screenModel
    required property var themePalette
    required property var metrics
    required property var overlayState
    required property var accessibilityState
    required property var audioService
    required property var brightnessService
    required property var networkService
    required property var bluetoothService
    property bool outputDevicesExpanded: false
    property bool inputDevicesExpanded: false
    property bool wifiExpanded: false
    property bool wifiConnectExpanded: false
    property string selectedWifiSsid: ""
    property bool selectedWifiSecured: false
    property bool hiddenWifi: false
    property bool bluetoothExpanded: false

    screen: screenModel
    visible: overlayState.activeOverlay === "gallery"
    color: "transparent"
    implicitWidth: 488
    implicitHeight: 840
    focusable: true

    anchors {
        top: true
        right: true
    }
    margins {
        top: metrics.space4
        right: metrics.space4
    }

    Surface {
        anchors.fill: parent
        themePalette: window.themePalette
        surfaceRadius: window.metrics.radiusLarge

        Keys.enabled: window.visible
        Keys.priority: Keys.BeforeItem
        Keys.onEscapePressed: event => {
            window.overlayState.close()
            event.accepted = true
        }

        Behavior on opacity {
            NumberAnimation { duration: window.accessibilityState.reducedMotion ? 0 : window.metrics.motionMs }
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: window.metrics.space6
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
            width: parent.width
            spacing: window.metrics.space4

            Item {
                width: parent.width
                height: closeButton.height

                Text {
                    anchors {
                        left: parent.left
                        right: closeButton.left
                        rightMargin: window.metrics.space3
                        verticalCenter: parent.verticalCenter
                    }
                    text: "Shell foundations"
                    elide: Text.ElideRight
                    color: window.themePalette.foreground
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }
                SvgButton {
                    id: closeButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    themePalette: window.themePalette
                    iconSource: "../assets/icons/close.svg"
                    accessibleName: "Close shell gallery"
                    onClicked: window.overlayState.close()
                }
            }

            Text {
                text: "Phase 1 component gallery · " + window.screenModel.name
                color: window.themePalette.muted
                font.pixelSize: 12
            }

            Grid {
                width: parent.width
                columns: 2
                spacing: window.metrics.space3
                ToggleTile {
                    themePalette: window.themePalette
                    iconSource: "../assets/icons/audio.svg"
                    title: "Sound"
                    detail: window.audioService.outputAvailable
                        ? Math.round(window.audioService.outputVolume * 100) + "%" : "No output device"
                    active: window.audioService.outputAvailable && !window.audioService.outputMuted
                    onClicked: window.audioService.toggleOutputMute()
                }
                ToggleTile {
                    themePalette: window.themePalette
                    iconSource: "../assets/icons/audio.svg"
                    title: "Microphone"
                    detail: window.audioService.inputAvailable
                        ? Math.round(window.audioService.inputVolume * 100) + "%" : "No input device"
                    active: window.audioService.inputAvailable && !window.audioService.inputMuted
                    onClicked: window.audioService.toggleInputMute()
                }
                ToggleTile {
                    themePalette: window.themePalette
                    iconSource: "../assets/icons/wifi.svg"
                    title: "Wi-Fi"
                    detail: !window.networkService.available ? window.networkService.error
                        : !window.networkService.wifiEnabled ? "Off"
                        : window.networkService.connected ? window.networkService.ssid
                        : window.networkService.reconnecting ? "Reconnecting…"
                        : "On · not connected"
                    active: window.networkService.wifiEnabled && window.networkService.connected
                    enabled: window.networkService.available
                    onClicked: window.networkService.toggleWifi()
                }
                ToggleTile {
                    themePalette: window.themePalette
                    iconSource: "../assets/icons/bluetooth.svg"
                    title: "Bluetooth"
                    detail: !window.bluetoothService.available ? window.bluetoothService.error
                        : !window.bluetoothService.powered ? "Off"
                        : window.bluetoothService.connectedDevice !== "" ? window.bluetoothService.connectedDevice
                        : "On · no device connected"
                    active: window.bluetoothService.powered
                    enabled: window.bluetoothService.available
                    onClicked: window.bluetoothService.togglePower()
                }
            }

            DeviceRow {
                width: parent.width
                visible: window.networkService.available && window.networkService.wifiEnabled
                themePalette: window.themePalette
                title: "Wi-Fi networks"
                detail: window.wifiExpanded ? "Hide networks" : "Show available networks"
                connected: window.networkService.connected
                onClicked: {
                    window.wifiExpanded = !window.wifiExpanded
                    if (window.wifiExpanded) window.networkService.refreshNetworks()
                }
            }
            Column {
                width: parent.width
                visible: window.wifiExpanded
                spacing: 2

                StatusMessage {
                    width: parent.width
                    visible: window.networkService.actionError !== ""
                    themePalette: window.themePalette
                    title: "Wi-Fi action failed"
                    detail: window.networkService.actionError
                }
                DeviceRow {
                    width: parent.width
                    visible: window.networkService.connected
                    themePalette: window.themePalette
                    title: window.networkService.ssid
                    detail: "Connected · click to disconnect"
                    connected: true
                    onClicked: window.networkService.disconnect()
                }
                DeviceRow {
                    width: parent.width
                    visible: window.networkService.networks.length === 0
                    themePalette: window.themePalette
                    title: "No networks found"
                    detail: "Scan again"
                    onClicked: window.networkService.refreshNetworks()
                }
                Repeater {
                    model: window.networkService.networks
                    delegate: DeviceRow {
                        required property var modelData
                        width: parent.width
                        visible: !modelData.active
                        themePalette: window.themePalette
                        title: modelData.ssid
                        detail: "Signal " + modelData.signal + "%" + (modelData.secured ? " · secured" : " · open")
                        connected: false
                        onClicked: {
                            if (modelData.secured) {
                                window.selectedWifiSsid = modelData.ssid
                                window.selectedWifiSecured = true
                                window.hiddenWifi = false
                                window.wifiConnectExpanded = true
                            } else {
                                window.networkService.connect(modelData.ssid, "", false)
                            }
                        }
                    }
                }
                DeviceRow {
                    width: parent.width
                    themePalette: window.themePalette
                    title: "Join hidden network"
                    detail: window.wifiConnectExpanded && window.hiddenWifi ? "Hide connection form" : "Enter network name and password"
                    onClicked: {
                        if (window.hiddenWifi && window.wifiConnectExpanded) {
                            window.wifiConnectExpanded = false
                        } else {
                            window.hiddenWifi = true
                            window.selectedWifiSsid = ""
                            window.selectedWifiSecured = true
                            window.wifiConnectExpanded = true
                        }
                    }
                }
                Column {
                    width: parent.width
                    visible: window.wifiConnectExpanded
                    spacing: window.metrics.space2

                    Text {
                        text: window.hiddenWifi ? "Hidden Wi-Fi network" : "Connect to " + window.selectedWifiSsid
                        color: window.themePalette.foreground
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                    TextField {
                        id: wifiNameField
                        width: parent.width
                        visible: window.hiddenWifi
                        placeholderText: "Network name (SSID)"
                        text: window.selectedWifiSsid
                        Accessible.name: "Hidden Wi-Fi network name"
                    }
                    TextField {
                        id: wifiPasswordField
                        width: parent.width
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        Accessible.name: "Wi-Fi password"
                    }
                    Button {
                        text: "Connect"
                        enabled: window.hiddenWifi ? wifiNameField.text.trim().length > 0 : window.selectedWifiSsid !== ""
                        Accessible.name: "Connect to Wi-Fi network"
                        onClicked: {
                            const name = window.hiddenWifi ? wifiNameField.text.trim() : window.selectedWifiSsid
                            window.networkService.connect(name, wifiPasswordField.text, window.hiddenWifi)
                            wifiPasswordField.text = ""
                        }
                    }
                }
                Text {
                    width: parent.width
                    visible: window.networkService.savedNetworks.length > 0
                    text: "Saved Wi-Fi networks"
                    color: window.themePalette.foreground
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
                Repeater {
                    model: window.networkService.savedNetworks
                    delegate: DeviceRow {
                        required property var modelData
                        width: parent.width
                        themePalette: window.themePalette
                        title: modelData
                        detail: modelData === window.networkService.ssid ? "Connected" : "Saved · click to connect"
                        connected: modelData === window.networkService.ssid
                        onClicked: window.networkService.activateProfile(modelData)
                    }
                }
                Text {
                    width: parent.width
                    visible: window.networkService.vpns.length > 0
                    text: "VPN"
                    color: window.themePalette.foreground
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
                Repeater {
                    model: window.networkService.vpns
                    delegate: DeviceRow {
                        required property var modelData
                        width: parent.width
                        themePalette: window.themePalette
                        title: modelData.name
                        detail: modelData.active ? "Connected · click to disconnect" : "Disconnected · click to connect"
                        connected: modelData.active
                        onClicked: {
                            if (modelData.active) window.networkService.deactivateVpn(modelData.name)
                            else window.networkService.activateProfile(modelData.name)
                        }
                    }
                }
            }

            DeviceRow {
                width: parent.width
                visible: window.bluetoothService.available && window.bluetoothService.powered
                themePalette: window.themePalette
                title: "Bluetooth devices"
                detail: window.bluetoothExpanded ? "Hide paired devices" : "Show paired devices"
                connected: window.bluetoothService.connectedDevice !== ""
                onClicked: window.bluetoothExpanded = !window.bluetoothExpanded
            }
            Column {
                width: parent.width
                visible: window.bluetoothExpanded
                spacing: 2

                StatusMessage {
                    width: parent.width
                    visible: window.bluetoothService.error !== ""
                    themePalette: window.themePalette
                    title: "Bluetooth action failed"
                    detail: window.bluetoothService.error
                }
                DeviceRow {
                    width: parent.width
                    themePalette: window.themePalette
                    title: window.bluetoothService.discovering ? "Scanning Bluetooth devices…" : "Scan Bluetooth devices"
                    detail: window.bluetoothService.discovering ? "Discovery ends in a few seconds" : "Find nearby devices"
                    onClicked: window.bluetoothService.scan()
                }
                DeviceRow {
                    width: parent.width
                    visible: window.bluetoothService.pairedDevices.length === 0
                    themePalette: window.themePalette
                    title: "No paired devices"
                    detail: "Scan to find a device to pair"
                }
                Repeater {
                    model: window.bluetoothService.pairedDevices
                    delegate: Column {
                        required property var modelData
                        width: parent.width
                        spacing: 2

                        DeviceRow {
                            width: parent.width
                            themePalette: window.themePalette
                            title: modelData.name
                            detail: modelData.address === window.bluetoothService.connectedAddress
                                ? "Connected · click to disconnect" : "Paired · click to connect"
                            connected: modelData.address === window.bluetoothService.connectedAddress
                            onClicked: {
                                if (modelData.address === window.bluetoothService.connectedAddress)
                                    window.bluetoothService.disconnect()
                                else
                                    window.bluetoothService.connect(modelData.address)
                            }
                        }
                        Button {
                            text: "Forget " + modelData.name
                            Accessible.name: "Forget paired Bluetooth device " + modelData.name
                            onClicked: window.bluetoothService.forget(modelData.address)
                        }
                    }
                }
                Repeater {
                    model: window.bluetoothService.discoveredDevices
                    delegate: DeviceRow {
                        required property var modelData
                        width: parent.width
                        visible: !window.bluetoothService.isPaired(modelData.address)
                        enabled: !window.bluetoothService.pairing
                        themePalette: window.themePalette
                        title: modelData.name
                        detail: window.bluetoothService.pairing
                            ? "Pairing another device…" : "Not paired · click to pair"
                        connected: false
                        onClicked: window.bluetoothService.pair(modelData.address)
                    }
                }
            }

            Text { text: "Output · " + Math.round(window.audioService.outputVolume * 100) + "%"; color: window.themePalette.foreground; font.pixelSize: 13; font.weight: Font.DemiBold }
            LevelSlider {
                width: parent.width
                enabled: window.audioService.outputAvailable
                themePalette: window.themePalette
                accessibleName: "Output volume"
                from: 0; to: 150
                value: window.audioService.outputVolume * 100
                onMoved: window.audioService.setOutputVolume(value / 100)
            }

            DeviceRow {
                width: parent.width
                themePalette: window.themePalette
                title: "Output devices"
                detail: window.outputDevicesExpanded ? "Hide devices" : "Choose output device"
                connected: window.audioService.outputAvailable
                onClicked: window.outputDevicesExpanded = !window.outputDevicesExpanded
            }
            Column {
                width: parent.width
                visible: window.outputDevicesExpanded
                Repeater {
                    model: window.audioService.nodes
                    delegate: DeviceRow {
                        required property var modelData
                        width: parent.width
                        visible: window.audioService.isOutputDevice(modelData)
                        themePalette: window.themePalette
                        title: modelData.description || modelData.name || "Audio output"
                        detail: modelData === window.audioService.output ? "Default output" : "Select output"
                        connected: modelData === window.audioService.output
                        onClicked: window.audioService.selectOutput(modelData)
                    }
                }
            }

            Text { text: "Input · " + (window.audioService.inputAvailable ? Math.round(window.audioService.inputVolume * 100) + "%" : "No input device"); color: window.themePalette.foreground; font.pixelSize: 13; font.weight: Font.DemiBold }
            LevelSlider {
                width: parent.width
                enabled: window.audioService.inputAvailable
                themePalette: window.themePalette
                accessibleName: "Input volume"
                from: 0; to: 150
                value: window.audioService.inputVolume * 100
                onMoved: window.audioService.setInputVolume(value / 100)
            }

            DeviceRow {
                width: parent.width
                themePalette: window.themePalette
                title: "Input devices"
                detail: window.inputDevicesExpanded ? "Hide devices" : "Choose input device"
                connected: window.audioService.inputAvailable
                onClicked: window.inputDevicesExpanded = !window.inputDevicesExpanded
            }
            Column {
                width: parent.width
                visible: window.inputDevicesExpanded
                Repeater {
                    model: window.audioService.nodes
                    delegate: DeviceRow {
                        required property var modelData
                        width: parent.width
                        visible: window.audioService.isInputDevice(modelData)
                        themePalette: window.themePalette
                        title: modelData.description || modelData.name || "Audio input"
                        detail: modelData === window.audioService.input ? "Default input" : "Select input"
                        connected: modelData === window.audioService.input
                        onClicked: window.audioService.selectInput(modelData)
                    }
                }
            }

            Text {
                text: window.brightnessService.available
                    ? "Brightness · " + Math.round(window.brightnessService.value) + "%"
                    : window.brightnessService.error
                color: window.brightnessService.available ? window.themePalette.foreground : window.themePalette.danger
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
            LevelSlider {
                width: parent.width
                enabled: window.brightnessService.available
                themePalette: window.themePalette
                accessibleName: "Brightness"
                value: window.brightnessService.value
                onMoved: window.brightnessService.setValue(value)
            }

            SegmentedChoice {
                themePalette: window.themePalette
                choices: [ "Saver", "Balanced", "Performance" ]
                currentIndex: 1
                onSelected: currentIndex = index
            }

            Rectangle { width: parent.width; height: 1; color: window.themePalette.border }

            StatusMessage {
                width: parent.width
                themePalette: window.themePalette
                title: "Service state"
                detail: "Audio, brightness, Wi-Fi, and Bluetooth radio use live system state. Device management arrives next."
            }
            }
        }
    }
}
