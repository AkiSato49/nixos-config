# Quickshell hardware capability audit

Research date: 2026-08-24.

Purpose: map real `casino` hardware and desktop daemons to native data sources before designing prettier Control Centre components. This is an architecture/design inventory, not a migration authorization. Keep legacy tools active until each replacement passes its phase acceptance checks.

## Decision summary

Build **signal-driven service adapters** first. Components receive small presentation models and emit intents; they never call DBus, `nmcli`, or `bluetoothctl` directly.

| Capability | `casino` support | Preferred source/action seam | Component family | Decision |
|---|---|---|---|---|
| Output/input volume, mute, device switch | Confirmed PipeWire + WirePlumber | Existing `Quickshell.Services.Pipewire` | `AudioTile`, `AudioDetail`, `DevicePicker`, `LevelSlider` | Keep native QS service |
| Brightness | `intel_backlight`, 38% current | `brightnessctl`; debounced readback | `BrightnessTile`, `LevelSlider` | Keep process adapter; no need DBus |
| Battery + AC | `BAT0`, AC, two USB-C source devices | QS UPower service / UPower DBus | `BatteryTile`, `PowerDetail`, `MetricRow` | Ready for Phase 4 |
| Power profiles | saver, balanced, performance; Intel P-state + platform profile | power-profiles-daemon DBus | `PowerProfileSegment`, `StatusPill` | Ready for Phase 4 |
| Wi-Fi | `wlp0s20f3`; hardware/radio enabled, currently disconnected | NetworkManager DBus; temporary `nmcli` | `ConnectivityTile`, `NetworkSheet`, `CredentialSheet` | Hardware exists; validate current adapter first |
| Mobile broadband | `wwan0mbim0`, connected to `telstra` | NetworkManager DBus | `ConnectivityTile`, `ConnectionRow` | Add to connectivity model; do not label it Wi-Fi |
| VPN / overlays | Tailscale tunnel active; Docker bridges active | NetworkManager connection/active-connection model | `VpnRow`, optional advanced network list | Show user-facing VPN only; hide bridge/veth noise |
| Bluetooth | BlueZ controller `9C:65:EB:FA:19:45`, powered | BlueZ DBus / QS Bluetooth after compatible QS upgrade | `BluetoothTile`, `BluetoothSheet`, `PairingSheet`, `DeviceRow` | Just Works path works now; full pairing needs Agent1 UI |
| Bluetooth battery | Hardware/BlueZ can expose it only per remote device | BlueZ `Battery1`, nullable | `DeviceRow` trailing battery indicator | Conditional; never invent 0% when property absent |
| Media | PipeWire available; player presence varies | QS MPRIS service | `MediaCard`, `TransportCluster`, `SeekBar` | Build lazy/conditional view |
| Notifications | Mako currently inactive | QS NotificationServer **or** Mako, never both | `NotificationToast`, `NotificationCentre`, `FocusMenu` | Decide server ownership before Phase 5 |
| Session controls | systemd-logind | logind DBus capability checks then actions | `SessionMenu`, `ConfirmSheet` | Ready once policy behavior tested |
| Screen lock | Hyprland 0.54; GTKLock remains recovery path | QS `WlSessionLock` + PAM | `LockScreen`, `AuthenticationIsland` | Phase 7 only; safety-critical |
| Displays | current eDP-1: 2880×1800, scale 1.5; dock topology later | Hyprland IPC for topology; compositor display protocol for surfaces | `DisplayTile`, `DisplaySheet` | Read-only summary first; no display mutation in v1 |
| Night light | no `hyprsunset`, `gammastep`, or `wlsunset` command found | First define one existing policy/service | `NightLightTile` | Blocked: no source of truth configured |

## Local hardware evidence

Read-only audit commands ran on `casino`:

```text
Quickshell: 0.2.1 (Nixpkgs package)
Hyprland: 0.54.0
Battery: BAT0, discharging, 44%, 22.17 Wh / 50.79 Wh, 7.411 W, 3.0 h remaining
Power profiles: power-saver (active), balanced, performance
Brightness: intel_backlight, 38%
Wi-Fi: wlp0s20f3; radio and hardware switch enabled
WWAN: wwan0mbim0 connected, profile telstra
Bluetooth: controller powered; central + peripheral roles
Audio: internal speakers; two internal microphone sources; PipeWire + WirePlumber
Current display: eDP-1, 2880×1800, scale 1.5
```

This audit must be repeated docked. Do not presume DP-10/DP-8 availability from an undocked readout.

## Source-of-truth rules

### Power, battery, and profiles

UPower `DisplayDevice` aggregates battery state and exposes percentage, energy, energy-full, energy-rate, time-to-empty/full, state, voltage, and temperature where hardware supplies them. Use it for primary battery UI; show optional figures only when present. [UPower device reference](https://upower.freedesktop.org/docs/Device.html)

Power Profiles Daemon exposes `ActiveProfile`, `Profiles`, and `PerformanceDegraded`. Read `Profiles` rather than assuming performance exists; show degradation reason as status, not a broken control. [power-profiles-daemon DBus reference](https://power-profiles-daemon-3v1n0-b70231ec1c573ac1bbe38f86440a681ab59.pages.freedesktop.org/gdbus-org.freedesktop.UPower.PowerProfiles.html)

Quickshell's UPower service exposes the display device and connected devices. It requires UPower daemon. [QS UPower](https://quickshell.org/docs/types/Quickshell.Services.UPower/UPower)

### Network and mobile broadband

NetworkManager owns Wi-Fi radio state, devices, access points, saved settings, active connections, and VPN state. Wireless DBus API provides `RequestScan`, AP lists, active AP, and AP add/remove signals. Manager API provides `WirelessEnabled`, active connections, `ActivateConnection`, and `AddAndActivateConnection`. [NetworkManager DBus specification](https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/gdbus-org.freedesktop.NetworkManager.html) · [wireless device API](https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/gdbus-org.freedesktop.NetworkManager.Device.Wireless.html)

Design one connectivity domain with typed transport rows: Wi-Fi, Ethernet, WWAN, VPN, tunnel. Filter Docker bridges, veths, loopback, and Wi-Fi P2P from default UI. This avoids current false model where “network” means only Wi-Fi.

Quickshell Networking documentation describes a NetworkManager backend and Wi-Fi/wired device types, but published docs are v0.3.0 while installed QS is v0.2.1. Do **not** import that API without a deliberate Quickshell upgrade and proof-of-build. [QS Networking v0.3.0](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/Networking/)

### Bluetooth

BlueZ Adapter1 owns powered/discovering/pairable adapter state. Device1 owns paired, connected, trusted, blocked, alias, and UUID state. Battery1 exposes a remote-device percentage only where supported. [BlueZ API](https://bluez.readthedocs.io/en/latest/)

Full pairing needs an `org.bluez.Agent1` implementation. Agent callbacks cover PIN, passkey, displayed passkey, numeric confirmation, authorization, and service authorization; manager registers agent capability. A `NoInputNoOutput` process path only covers Just Works cases. [BlueZ Agent API](https://bluez.readthedocs.io/en/latest/agent-api/)

Quickshell Bluetooth docs are also v0.3.0, newer than active QS 0.2.1. Keep bounded `bluetoothctl` adapter until upgrade decision; do not begin a QML DBus agent without explicit BlueZ Agent1 flow design. [QS Bluetooth v0.3.0](https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/)

### Media, notifications, and session controls

MPRIS player interface publishes playback state, position, metadata, and capability flags. Check each `Can*` flag before enabling controls. [MPRIS v2.2](https://specifications.freedesktop.org/mpris/latest/Player_Interface.html) · [QS MPRIS](https://quickshell.org/docs/v0.2.1/types/Quickshell.Services.Mpris/)

Desktop notification actions are key/label pairs; urgency is low/normal/critical; critical notifications must not expire. A notification server advertises supported capabilities. [Desktop Notifications spec](https://specifications.freedesktop.org/notification/latest/)

systemd-logind exposes `CanPowerOff`, `CanReboot`, `CanSuspend`, and `CanHibernate` capability checks plus matching actions. Query capability before rendering active actions; policy may return `challenge` or `no`. [logind DBus API](https://www.freedesktop.org/software/systemd/man/latest/org.freedesktop.login1.html)

QS `WlSessionLock` is security-sensitive: if a lock dies before explicit unlock, compliant compositors retain an opaque lock surface. Only Phase 7 may use it. [QS WlSessionLock](https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlSessionLock/)

## Reusable prettier-component system

Build component primitives around information density, not feature names.

### Primitives

| Primitive | Responsibility | States |
|---|---|---|
| `ControlTile` | Compact entry point: icon, title, one live metric, active marker | normal, active, unavailable, attention |
| `DetailSheet` | Expanded scrollable feature surface with title/action region | open, loading, error |
| `SettingRow` | Selectable item: leading icon, primary/secondary text, trailing state | default, selected, disabled, destructive |
| `TrailingMetric` | Small right-aligned semantic value | percent, time, text, icon, unavailable |
| `StatusPill` | Short state label, never a button | connected, charging, degraded, unavailable |
| `ConfirmSheet` | Explicit commit/cancel for forget, reboot, power off | idle, pending, failure |
| `CredentialSheet` | SSID + password/hidden-network form | input, connecting, auth failed |
| `EmptyState` | Explain no hardware/data and give one recovery action | unavailable, permission, none found |

### Feature compositions

```text
ControlCentre
├── ControlTile grid
│   ├── AudioTile      -> AudioDetail      -> DevicePicker + LevelSlider
│   ├── ConnectivityTile -> NetworkSheet  -> ConnectionRow + CredentialSheet
│   ├── BluetoothTile  -> BluetoothSheet  -> DeviceRow + PairingSheet + ConfirmSheet
│   ├── PowerTile      -> PowerDetail     -> BatterySummary + PowerProfileSegment
│   └── FocusTile      -> FocusMenu       -> duration choices
├── MediaCard          -> TransportCluster + SeekBar
└── SessionMenu        -> ConfirmSheet
```

### Visual rules for this shell

- Use compact tile as **status + one primary gesture**, not mini settings page.
- Open detail sheet only for multi-device, credential, destructive, or duration choices.
- Give every row a trailing semantic: connected dot, battery, percentage, `Off`, or chevron. No decorative empty space.
- Reserve accent fill for active mode/selected route. Use muted text for supporting data. Use danger only in confirmation paths.
- Pair visual rhythm: 8px row radius, 14px grouped controls, 22px panel. Use 8/12/16/24px gaps only.
- For battery and signal, prefer text plus icon/pill over color alone.
- Animate sheet/tile geometry at 180ms; zero duration when reduced motion is set.
- Show loading, unavailable, permission/policy, and action-failure states as first-class layouts.

## Recommended build order after Phase 3 acceptance

1. Add `PowerService` with UPower and power-profiles-daemon; no display/night-light control yet.
2. Build `BatterySummary`, `PowerProfileSegment`, `StatusPill`, and `TrailingMetric` against live data.
3. Define one notification-server decision before drawing notification UI.
4. Upgrade Quickshell only if tested APIs eliminate enough adapter code to justify compatibility cost; otherwise use narrow DBus adapters.
5. Design BlueZ `Agent1` pairing state machine on paper before implementation: idle → discover → select → credential/confirmation → pairing → trusted/connected or actionable failure.
6. Keep lockscreen last; it needs independent security/recovery review.

## Open decisions

- Which night-light daemon/policy owns state and actions?
- Does user-facing Control Centre show WWAN data/radio controls, or only cellular connection state?
- Does Tailscale get a first-class VPN control, or status-only because Tailscale daemon owns connection lifecycle?
- Is Quickshell upgrade from 0.2.1 acceptable before networking/Bluetooth DBus migration?
- Which compact-panel layout wins: two-column tile grid plus sheets, or vertical grouped cards with inline expansion?
