# Quickshell shell handoff

Read [`quickshell-full-shell-plan.md`](quickshell-full-shell-plan.md) first. Continue phase-by-phase; do not retire legacy desktop tools before matching QS acceptance tests pass.

## Current phase

Phase 3 has started after user-confirmed Phase 2 hardware acceptance. Phase 0 is complete. Phase 1 visual gallery is mostly accepted.

## Confirmed working

- `quickshell-lawliet.service` launches `lawliet-shell`.
- `qs-control-centre` idempotently opens panel.
- `qs-toggle-control-centre` toggles panel.
- `SUPER+CTRL+C` maps to `qs-toggle-control-centre`.
- Gallery renders correctly across configured displays.
- Escape and keyboard focus/Tab behavior work.
- QML palette/metrics are generated from Nix Gruvbox theme values.
- Native PipeWire default sink/source service works.
- `PwObjectTracker` is required; without it `audio.volume` became `NaN`.
- Output/input volume and mute work through `Quickshell.Services.Pipewire`.
- Output/input device selectors use `Pipewire.nodes` and
  `preferredDefaultAudioSink` / `preferredDefaultAudioSource`.
- Brightness uses argument-array `brightnessctl` processes, 75ms debounce, and readback.
- Slider visual fix: `LevelSlider.qml` needs `implicitHeight: 28`; without it custom sliders render at 0px.
- Native QS volume/brightness OSD has a 1.8s timeout. It renders normal, unavailable, and brightness-write-failure states.
- `qs-volume-{up,down,mute}`, `qs-mic-mute`, and `qs-brightness-{up,down}` retain `wpctl`/`brightnessctl` as action paths, then call QS IPC for OSD. Hyprland hardware bindings use these wrappers.
- `NetworkService.qml` now reads Wi-Fi adapter/radio/active SSID, scans saved Wi-Fi and VPN profiles, toggles radio, scans networks, connects/disconnects Wi-Fi, and activates/deactivates saved profiles through argument-array `nmcli` processes.
- Wi-Fi detail UI has secured-network password prompt, hidden-SSID form, saved-network rows, and VPN status/action rows. SSIDs are validated to 1–32 characters before connection.
- Wi-Fi enable needs asynchronous NetworkManager reconnection. `reconnectTimer` retries state reads every 2s for at most 10s; do not replace it with permanent polling.
- `BluetoothService.qml` reads adapter/power/connected device, toggles power, lists paired devices, connects/disconnects and forgets paired devices, pairs NoInputNoOutput devices with a bounded 30s `bluetoothctl` process, and runs bounded 6s discovery through argument-array `bluetoothctl` processes.
- Bluetooth pairing supports Just Works devices. PIN/numeric-confirmation devices return a clear fallback to system Bluetooth settings until BlueZ DBus agent UI exists.
- QS panel default state is closed. `OverlayState.activeOverlay` must remain `""`; defaulting it to `"gallery"` creates an uncloseable-looking panel on service restart.

## Important files

```text
modules/home/desktop/quickshell.nix
modules/home/desktop/quickshell/shell.qml
modules/home/desktop/quickshell/services/AudioService.qml
modules/home/desktop/quickshell/services/BrightnessService.qml
modules/home/desktop/quickshell/services/NetworkService.qml
modules/home/desktop/quickshell/services/BluetoothService.qml
modules/home/desktop/quickshell/windows/ComponentGallery.qml
modules/home/desktop/quickshell/components/LevelSlider.qml
modules/home/desktop/hyprland.nix
home/lawliet.nix
```

## Next work

1. Hardware-test Wi-Fi password, hidden SSID, saved-profile, VPN, radio, reconnect, scan, unavailable adapter, and failed-action states. `nmcli` errors surface short actionable messages; inspect journal for exact failures.
2. Hardware-test Bluetooth radio, 6s discovery, Just Works pairing, forget pairing, paired-device connect/disconnect, unavailable adapter, and failed-action states. PIN/numeric-confirmation pairing remains intentionally delegated to Bluetooth settings.
3. Replace temporary `nmcli`/`bluetoothctl` adapters with NetworkManager/BlueZ DBus only when QML DBus integration is proven narrower and signal-driven.
4. Decide whether BlueZ DBus agent UI is worth adding for PIN/numeric-confirmation pairing; do not fake successful pairing without a real confirmation path.
5. Verify OSD placement across eDP-1, DP-10, and portrait DP-8. It targets active client's Hyprland monitor, falling back to focused monitor when no client is active.
6. Verify Control Centre `ScrollView`: wheel, touchpad, Tab traversal, password-field focus, and slider dragging with expanded device lists.

## Known constraints / caveats

- OSD uses no animation, so reduced-motion needs no alternate transition path.
- Gallery body already uses `ScrollView`; Phase 3 device lists can grow without clipping.
- QS `Variants` accept one delegate. Keep `ComponentGallery` and `OnScreenDisplay` in separate `Variants` blocks, otherwise later delegate silently replaces gallery.
- `bluetoothctl` discovery is globally stateful. Current implementation always stops scanning after 6s; preserve bounded discovery.
- `HyprlandFocusGrab` was removed: it immediately cleared state for this non-focused layer panel. Escape and global toggle are current close paths.
- No lockscreen/PAM changes. GTKLock remains active recovery path.
- Existing legacy Waybar, Mako, Wofi, l1p0 menus, GTKLock, and Hypridle remain intentionally enabled.
- Repo was already broadly dirty before QS work. QS files are staged; never mass-stage or commit unrelated workstation changes.
- Flake evaluation excludes untracked files. Stage every new QML file before `nixos-rebuild`; otherwise Nix copies a config missing that file and QS fails at startup.
- During this dirty-worktree session, live QS config was manually repointed at exact generated Nix-store output before restarting service. Normal recovery/persistence remains `sudo nixos-rebuild switch --flake /etc/nixos#casino`; never choose an arbitrary old `/nix/store/*-lawliet-shell-config` path.

## Validation

```sh
nix-instantiate --parse modules/home/desktop/quickshell.nix
nix-instantiate --parse modules/home/desktop/hyprland.nix
nixos-rebuild build --flake /etc/nixos#casino
git diff --check
sudo nixos-rebuild switch --flake /etc/nixos#casino
systemctl --user restart quickshell-lawliet
journalctl --user -u quickshell-lawliet -b -n 40 --no-pager
```
