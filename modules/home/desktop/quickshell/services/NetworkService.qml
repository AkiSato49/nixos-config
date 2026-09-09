import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property bool available: false
    property bool wifiEnabled: false
    property bool connected: false
    property string ssid: ""
    property string wifiDevice: ""
    property string error: ""
    property bool reconnecting: false
    property int reconnectAttempts: 0
    property var networks: []
    property var savedNetworks: []
    property var vpns: []
    property string pendingSsid: ""
    property string pendingPassword: ""
    property bool pendingHidden: false
    property string pendingProfile: ""
    property string actionError: ""

    function refresh(): void {
        if (!deviceReader.running) deviceReader.running = true
        if (!savedNetworkReader.running) savedNetworkReader.running = true
        if (!vpnReader.running) vpnReader.running = true
    }

    function refreshNetworks(): void {
        if (available && wifiEnabled && !scanReader.running) scanReader.running = true
    }

    function validSsid(value: string): bool {
        return value.trim().length > 0 && value.length <= 32
    }

    function connect(ssid: string, password: string, hidden: bool): void {
        if (!validSsid(ssid)) {
            actionError = "Network name must contain 1–32 characters"
            return
        }
        pendingSsid = ssid
        pendingPassword = password
        pendingHidden = hidden
        actionError = ""
        if (!connectWriter.running) connectWriter.running = true
    }

    function activateProfile(name: string): void {
        if (name === "") return
        pendingProfile = name
        actionError = ""
        if (!profileUpWriter.running) profileUpWriter.running = true
    }

    function deactivateVpn(name: string): void {
        if (name === "") return
        pendingProfile = name
        actionError = ""
        if (!profileDownWriter.running) profileDownWriter.running = true
    }

    function disconnect(): void {
        actionError = ""
        if (available && connected && !disconnectWriter.running) disconnectWriter.running = true
    }

    function toggleWifi(): void {
        if (!available) return
        error = ""
        if (wifiEnabled) {
            if (!radioOff.running) radioOff.running = true
        } else if (!radioOn.running) {
            radioOn.running = true
        }
    }

    function parseDevices(text: string): void {
        const lines = text.trim().split("\n")
        wifiDevice = ""
        for (let index = 0; index < lines.length; index++) {
            const fields = lines[index].split(":")
            if (fields.length >= 2 && fields[1] === "wifi") {
                wifiDevice = fields[0]
                break
            }
        }
        available = wifiDevice !== ""
        if (!available) {
            connected = false
            ssid = ""
            error = "Wi-Fi adapter unavailable"
        }
    }

    function parseRadio(text: string): void {
        wifiEnabled = text.trim() === "enabled"
        if (!wifiEnabled) {
            connected = false
            ssid = ""
        }
    }

    function parseNetworks(text: string): void {
        const entries = []
        const lines = text.trim().split("\n")
        for (let index = 0; index < lines.length; index++) {
            const fields = lines[index].split(":")
            if (fields.length < 4 || fields[1] === "") continue
            entries.push({
                active: fields[0] === "*",
                ssid: fields[1],
                signal: Number(fields[2]) || 0,
                secured: fields.slice(3).join(":") !== ""
            })
        }
        networks = entries
    }

    function parseSavedNetworks(text: string): void {
        const entries = []
        const lines = text.trim().split("\n")
        for (let index = 0; index < lines.length; index++) {
            const fields = lines[index].split(":")
            if (fields.length >= 2 && fields[0] !== "" && fields[1] === "802-11-wireless") entries.push(fields[0])
        }
        savedNetworks = entries
    }

    function parseVpns(text: string): void {
        const entries = []
        const lines = text.trim().split("\n")
        for (let index = 0; index < lines.length; index++) {
            const fields = lines[index].split(":")
            if (fields.length >= 3 && (fields[1] === "vpn" || fields[1] === "wireguard")) {
                entries.push({ name: fields[0], active: fields[2] !== "" && fields[2] !== "--" })
            }
        }
        vpns = entries
    }

    function parseConnection(text: string): void {
        ssid = text.trim()
        connected = ssid !== "" && ssid !== "--"
        if (!connected) ssid = ""
        if (connected) {
            reconnecting = false
            reconnectAttempts = 0
            reconnectTimer.stop()
        }
    }

    function afterAction(exitCode: int, message: string, waitForWifi: bool): void {
        if (exitCode !== 0) actionError = message
        refresh()
        if (waitForWifi) {
            reconnecting = exitCode === 0
            reconnectAttempts = 5
            reconnectTimer.restart()
        }
    }

    Process {
        id: deviceReader
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseDevices(text)
                if (root.available && !radioReader.running) radioReader.running = true
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.available = false
                root.error = "NetworkManager unavailable"
            }
        }
    }
    Process {
        id: radioReader
        command: ["nmcli", "-t", "-f", "WIFI", "general", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseRadio(text)
                if (root.available && !connectionReader.running) connectionReader.running = true
            }
        }
    }
    Process {
        id: connectionReader
        command: ["nmcli", "-g", "GENERAL.CONNECTION", "device", "show", root.wifiDevice]
        stdout: StdioCollector { onStreamFinished: root.parseConnection(text) }
    }
    Process {
        id: savedNetworkReader
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector { onStreamFinished: root.parseSavedNetworks(text) }
    }
    Process {
        id: vpnReader
        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "connection", "show"]
        stdout: StdioCollector { onStreamFinished: root.parseVpns(text) }
    }
    Process {
        id: scanReader
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "auto"]
        stdout: StdioCollector { onStreamFinished: root.parseNetworks(text) }
        onExited: exitCode => {
            if (exitCode !== 0) root.actionError = "Could not scan Wi-Fi networks. Check radio and adapter."
        }
    }
    Process {
        id: connectWriter
        command: {
            const args = ["nmcli", "device", "wifi", "connect", root.pendingSsid]
            if (root.pendingPassword !== "") args.push("password", root.pendingPassword)
            if (root.pendingHidden) args.push("hidden", "yes")
            return args
        }
        onExited: exitCode => root.afterAction(exitCode, "Could not connect to " + root.pendingSsid + ". Check password or network availability.", true)
    }
    Process {
        id: profileUpWriter
        command: ["nmcli", "connection", "up", "id", root.pendingProfile]
        onExited: exitCode => root.afterAction(exitCode, "Could not activate " + root.pendingProfile + ". Check saved credentials.", false)
    }
    Process {
        id: profileDownWriter
        command: ["nmcli", "connection", "down", "id", root.pendingProfile]
        onExited: exitCode => root.afterAction(exitCode, "Could not disconnect " + root.pendingProfile + ".", false)
    }
    Process {
        id: disconnectWriter
        command: ["nmcli", "device", "disconnect", root.wifiDevice]
        onExited: exitCode => root.afterAction(exitCode, "Could not disconnect Wi-Fi.", false)
    }
    Process {
        id: radioOn
        command: ["nmcli", "radio", "wifi", "on"]
        onStarted: {
            root.reconnecting = true
            root.reconnectAttempts = 5
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.reconnecting = false
                root.error = "Could not enable Wi-Fi"
            }
            root.refresh()
            reconnectTimer.restart()
        }
    }
    Process {
        id: radioOff
        command: ["nmcli", "radio", "wifi", "off"]
        onStarted: root.reconnecting = false
        onExited: exitCode => {
            if (exitCode !== 0) root.error = "Could not disable Wi-Fi"
            root.refresh()
        }
    }
    Timer {
        id: reconnectTimer
        interval: 2000
        repeat: true
        onTriggered: {
            if (root.connected || root.reconnectAttempts <= 0) {
                root.reconnecting = false
                stop()
                return
            }
            root.reconnectAttempts--
            root.refresh()
        }
    }

    Component.onCompleted: refresh()
}
