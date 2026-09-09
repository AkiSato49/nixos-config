# Quickshell control-center references

Research date: 2026-08-23.

## Shortlist

| Project | Why inspect it | Link |
|---|---|---|
| Quickshell Book | Small, focused learning examples for control-center, network menu, audio controls, Bluetooth manager, multi-monitor, and popup windows. Best implementation reference. | <https://github.com/programmersd21/the_quickshell_book> |
| snry-shell | Full production shell: bar, volume mixer, quick toggles, lock/session screens, power profiles, night light, microphone, Material You theming, and a settings GUI. Best feature-scope reference; selectively borrow patterns, not architecture. | <https://github.com/sonroyaalmerol/snry-shell> |
| Nandoroid Shell | Material 3 Quickshell desktop shell. Uses PipeWire/`wpctl`, NetworkManager/`nmcli`, and BlueZ/`bluetoothctl`; useful visual and service-integration reference. | <https://github.com/na-ive/nandoroid-shell> |
| Speshell | Compact Quickshell shell reference. Inspect for panel composition and restrained quick-setting layouts. | <https://github.com/vcoscrato/Speshell> |
| iNiR | Larger reactive Quickshell shell with documented service architecture for PipeWire, NetworkManager, BlueZ, battery, and notifications. | <https://github.com/snowarch/iNiR> |
| QuickshellRoundedCorners | Narrow reference for physical screen-corner overlays only. | <https://github.com/flores666/QuickshellRoundedCorners> |

## Creator repo from video

The video creator (`saneaspect`) publishes [dotfiles](https://github.com/saneaspect/dotfiles) and [test-dots](https://github.com/saneaspect/test-dots), but neither contains a Quickshell quick-settings/control-center implementation. The main repo is Hyprland + Waybar + Wofi.

## High-polish visual references

| Project | What to borrow | What not to copy |
|---|---|---|
| [Caelestia](https://github.com/caelestia-dots/shell) | Fluid expansion from compact trigger to grouped panel, clear radius/spacing hierarchy, cohesive motion. Its README describes it as a “fluid, morphing shell”. | Whole shell/runtime: it requires Quickshell git plus a separate CLI and broad service set. |
| [Noctalia](https://github.com/noctalia-dev/noctalia) | Information architecture: one consistent surface for control center, dock, launcher, notifications, lock/session actions, widgets, and multi-monitor bars. | Code/runtime. Current v5 is its own native Wayland/OpenGL shell, not a Quickshell config. |
| [Cartoon Shell](https://github.com/mailong2401/cartoon-shell) | Quickshell + Hyprland composition, playful visual hierarchy, panel affordances. | Its comic-font visual language and its full panel; use as a composition reference only. |
| [Brain Shell](https://github.com/Brainitech/Brain_Shell) | Closest structural reference: separate `QuickControl`, `AudioPopup`, `NetworkPopup`, `WifiTab`, `BluetoothTab`, reusable components, services, theme, state, and windows folders. `QuickControl.qml` pairs vertical audio and brightness sliders with a morphing right-edge popup. | Whole shell: v0.1.0, requires Hyprland 0.55+, Matugen, and its Nix flake is documented upstream as experimental/broken. It also lists mixed-resolution multi-monitor scaling as a known issue. |

## Build direction

Use Quickshell Book for window/component fundamentals. Use Caelestia for motion and panel geometry, Noctalia for feature hierarchy, and Cartoon Shell for Quickshell panel composition. Build a small independent control centre rather than importing any full shell.

Build own small service layer around existing system APIs:

- PipeWire: `wpctl`
- Wi-Fi: NetworkManager / `nmcli`
- Bluetooth: BlueZ / `bluetoothctl`
- Battery: UPower
- Power profile: `powerprofilesctl`

Do not clone a whole shell. Keep scope to control centre and its required service adapters.
