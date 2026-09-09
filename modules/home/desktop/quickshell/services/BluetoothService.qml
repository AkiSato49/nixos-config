import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property bool available: false
    property bool powered: false
    property string connectedDevice: ""
    property string connectedAddress: ""
    property var pairedDevices: []
    property var discoveredDevices: []
    property bool discovering: false
    property bool pairing: false
    property string pendingAddress: ""
    property string error: ""

    function refresh(): void {
        if (!adapterReader.running) adapterReader.running = true
        if (!connectionReader.running) connectionReader.running = true
        if (!pairedReader.running) pairedReader.running = true
    }

    function scan(): void {
        if (discovering || !powered) return
        error = ""
        discovering = true
        if (!scanStart.running) scanStart.running = true
        scanTimer.restart()
    }

    function isPaired(address: string): bool {
        for (let index = 0; index < pairedDevices.length; index++) {
            if (pairedDevices[index].address === address) return true
        }
        return false
    }

    function pair(address: string): void {
        if (address === "" || isPaired(address) || pairing) return
        pendingAddress = address
        pairing = true
        error = ""
        if (!pairWriter.running) pairWriter.running = true
    }

    function forget(address: string): void {
        if (!isPaired(address) || forgetWriter.running) return
        pendingAddress = address
        error = ""
        if (!forgetWriter.running) forgetWriter.running = true
    }

    function connect(address: string): void {
        if (!isPaired(address)) return
        pendingAddress = address
        error = ""
        if (!connectWriter.running) connectWriter.running = true
    }

    function disconnect(): void {
        if (connectedAddress === "") return
        pendingAddress = connectedAddress
        error = ""
        if (!disconnectWriter.running) disconnectWriter.running = true
    }

    function togglePower(): void {
        error = ""
        if (powered) {
            if (!powerOff.running) powerOff.running = true
        } else if (!powerOn.running) {
            powerOn.running = true
        }
    }

    function parseAdapter(text: string): void {
        available = text.indexOf("Controller ") !== -1
        powered = text.indexOf("Powered: yes") !== -1
        if (!available) error = "Bluetooth adapter unavailable"
    }

    function parseDevice(line: string): var {
        const fields = line.trim().split(" ")
        if (fields.length < 3 || fields[0] !== "Device") return null
        return { address: fields[1], name: fields.slice(2).join(" ") }
    }

    function parseDiscovered(text: string): void {
        const devices = []
        const lines = text.trim().split("\n")
        for (let index = 0; index < lines.length; index++) {
            const device = parseDevice(lines[index])
            if (device !== null) devices.push(device)
        }
        discoveredDevices = devices
    }

    function parsePaired(text: string): void {
        const devices = []
        const lines = text.trim().split("\n")
        for (let index = 0; index < lines.length; index++) {
            const device = parseDevice(lines[index])
            if (device !== null) devices.push(device)
        }
        pairedDevices = devices
    }

    function parseConnection(text: string): void {
        const device = parseDevice(text.trim().split("\n")[0])
        connectedAddress = device === null ? "" : device.address
        connectedDevice = device === null ? "" : device.name
    }

    Process {
        id: adapterReader
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector { onStreamFinished: root.parseAdapter(text) }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.available = false
                root.error = "Bluetooth adapter unavailable"
            }
        }
    }
    Process {
        id: connectionReader
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: StdioCollector { onStreamFinished: root.parseConnection(text) }
    }
    Process {
        id: scanStart
        command: ["bluetoothctl", "scan", "on"]
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.discovering = false
                root.error = "Could not start Bluetooth discovery"
            }
        }
    }
    Process {
        id: scanStop
        command: ["bluetoothctl", "scan", "off"]
        onExited: root.discovering = false
    }
    Process {
        id: discoveredReader
        command: ["bluetoothctl", "devices"]
        stdout: StdioCollector { onStreamFinished: root.parseDiscovered(text) }
        onExited: exitCode => {
            if (exitCode !== 0) root.error = "Could not read Bluetooth devices"
        }
    }
    Timer {
        id: scanTimer
        interval: 6000
        onTriggered: {
            if (!scanStop.running) scanStop.running = true
            if (!discoveredReader.running) discoveredReader.running = true
        }
    }
    Process {
        id: pairedReader
        command: ["bluetoothctl", "devices", "Paired"]
        stdout: StdioCollector { onStreamFinished: root.parsePaired(text) }
    }
    Process {
        id: pairWriter
        command: ["bluetoothctl", "--agent", "NoInputNoOutput", "--timeout", "30", "pair", root.pendingAddress]
        onExited: exitCode => {
            root.pairing = false
            if (exitCode !== 0) root.error = "Could not pair device. For PIN or confirmation pairing, use Bluetooth settings."
            root.refresh()
        }
    }
    Process {
        id: forgetWriter
        command: ["bluetoothctl", "remove", root.pendingAddress]
        onExited: exitCode => {
            if (exitCode !== 0) root.error = "Could not forget Bluetooth device"
            root.refresh()
        }
    }
    Process {
        id: connectWriter
        command: ["bluetoothctl", "connect", root.pendingAddress]
        onExited: exitCode => {
            if (exitCode !== 0) root.error = "Could not connect Bluetooth device"
            root.refresh()
        }
    }
    Process {
        id: disconnectWriter
        command: ["bluetoothctl", "disconnect", root.pendingAddress]
        onExited: exitCode => {
            if (exitCode !== 0) root.error = "Could not disconnect Bluetooth device"
            root.refresh()
        }
    }
    Process {
        id: powerOn
        command: ["bluetoothctl", "power", "on"]
        onExited: exitCode => {
            if (exitCode !== 0) root.error = "Could not enable Bluetooth"
            root.refresh()
        }
    }
    Process {
        id: powerOff
        command: ["bluetoothctl", "power", "off"]
        onExited: exitCode => {
            if (exitCode !== 0) root.error = "Could not disable Bluetooth"
            root.refresh()
        }
    }

    Component.onCompleted: refresh()
}
