# Full Quickshell shell plan

## Goal

Replace fragmented desktop overlays with one **small, native Quickshell shell** for Hyprland:

- top bar
- Control Centre / quick settings
- notification centre
- lockscreen
- launcher
- media and volume OSD
- session/power controls

Keep Hyprland as compositor and keep existing system services: NetworkManager, BlueZ, PipeWire/WirePlumber, UPower, power-profiles-daemon, fprintd, greetd/ReGreet, and GTKLock until Quickshell lock is proven safe.

This is **not** a full desktop-environment replacement. Do not import Caelestia, Noctalia, Brain Shell, Cartoon Shell, or Qylock wholesale. Borrow interaction patterns only. Their runtime assumptions, system dependencies, theme systems, and lock flows conflict with this configuration.

Reference research: [`quickshell-control-center-references.md`](quickshell-control-center-references.md).

---

## Why Quickshell

Current experimental Control Centre is Lit + WebKitGTK + Python bridge. It introduced three wrong seams:

1. WebKit process + `file://` asset access makes state loading and lifecycle fragile.
2. HTML communicates with system services through an ad-hoc bridge.
3. Nerd Font icons do not render reliably inside WebKit.

Quickshell gives QML/QtQuick direct Wayland layer-shell windows, Qt SVG rendering, animations, and native PipeWire/PAM services. It removes WebKit, Node/Vite/Lit, Python bridge, and font-glyph dependence from desktop overlay UI.

Use **inline SVG or Qt icon assets**, never Nerd Font glyphs, for interactive UI.

---

## Visual direction

Synthesize references; do not copy their source or theme.

| Reference | Borrow | Reject |
|---|---|---|
| Caelestia | compact trigger -> fluid expansion, coherent spacing/radius scale, intentional motion | whole shell/CLI stack, excessive motion |
| Noctalia | hierarchy and feature completeness | runtime and whole desktop-shell replacement |
| Brain Shell | popup/service/component folder boundaries; narrow vertical audio/brightness control | v0.1 upstream code, Matugen requirement, 1080p-centric layout |
| Qylock | lockscreen composition: background, time, focused auth island, full session lock | SDDM compatibility shim and its session-unlock implementation |
| Cartoon Shell | playful panel composition | comic-font visual language |

### Design rules

- Retain repo theme tokens from `modules/themes/*`; initial target is current Gruvbox light theme.
- Use three radii only: `8`, `14`, `22` logical px. Nested radius = outer radius minus inner inset.
- Use a 4px spacing grid: 8, 12, 16, 24, 32.
- Build visual hierarchy with contrast, size, and spacing—not random borders or every surface rounded.
- Main panels have one translucent surface, thin low-contrast border, restrained shadow.
- Standard motion: 160–220ms cubic easing. When user reduces motion, transition duration is zero.
- Use responsive logical dimensions and screen scale. Never hard-code pixel geometry for one monitor.
- All panel state must communicate unavailable/loading/error state. No permanent “Loading…” placeholders.

---

## Architecture

### File layout

Create a responsibility-named QML application. Do not create `utils`, `helpers`, `common`, or `shared` directories.

```text
modules/home/desktop/quickshell.nix
modules/home/desktop/quickshell/
├── shell.qml                         # ShellRoot; imports and root singletons only
├── theme/
│   ├── Palette.qml                   # theme values injected/generated from Nix
│   ├── Metrics.qml                   # scale, spacing, radii, animation duration
│   └── Icons.qml                     # SVG URL registry; no icon-font strings
├── state/
│   ├── OverlayState.qml              # exactly one active overlay and close policy
│   ├── ScreenState.qml               # per-screen selection and scale
│   └── AccessibilityState.qml        # reduced-motion, keyboard navigation
├── services/
│   ├── AudioService.qml              # PipeWire sink/source, MPRIS, volume actions
│   ├── NetworkService.qml            # NetworkManager state and Wi-Fi actions
│   ├── BluetoothService.qml          # BlueZ state and device actions
│   ├── PowerService.qml              # UPower, profile, brightness, night light
│   ├── NotificationService.qml       # notification history, DND
│   ├── SessionService.qml            # lock/suspend/reboot/power off
│   └── AuthenticationService.qml     # PAM transaction state for lock only
├── components/
│   ├── Surface.qml                   # panel surface with tokens
│   ├── SvgButton.qml                 # accessible icon button
│   ├── ToggleTile.qml                # icon, label, state, expandable action
│   ├── LevelSlider.qml               # audio/brightness; keyboard + pointer support
│   ├── DeviceRow.qml                 # paired network/audio/Bluetooth device row
│   ├── SegmentedChoice.qml           # power profile and similar choices
│   └── StatusMessage.qml             # empty/loading/error state
├── windows/
│   ├── TopBar.qml
│   ├── ControlCentre.qml
│   ├── NotificationCentre.qml
│   ├── Launcher.qml
│   ├── LockScreen.qml
│   └── OnScreenDisplay.qml
└── assets/
    └── icons/*.svg
```

Each window composes components and reads services. Components never run shell commands. Service interfaces hide all DBus/process details.

### Nix module responsibilities

`modules/home/desktop/quickshell.nix` must:

- install `pkgs.quickshell` and only runtime packages needed by enabled QML imports;
- write QML config under `~/.config/quickshell/lawliet-shell/` using Home Manager;
- generate `Palette.qml` from `theme.colors` and `Metrics.qml` from theme geometry;
- add a `systemd --user` service, ordered after `graphical-session.target` and tied to it;
- expose deterministic commands: `qs-shell`, `qs-control-centre`, `qs-lock`, `qs-launcher`;
- use `Restart=on-failure`, not uncontrolled restart loops;
- retain existing Waybar, GTKLock, l1p0 menus, mako, and Wofi until their QS replacements pass acceptance checks.

Do not add a dependency without naming what it replaces.

### System integration strategy

Prefer first-party Quickshell services where they cover the need:

- `Quickshell.Services.Pipewire` for default audio device, volume, mute, and device tracking;
- `Quickshell.Services.Pam` for lockscreen authentication;
- Wayland `WlSessionLock` for actual lock surfaces.

For remaining services, choose DBus over polling shell commands:

| Domain | Source of truth | Action path |
|---|---|---|
| Wi-Fi / Ethernet / VPN | NetworkManager DBus | NetworkManager DBus; temporary `nmcli` adapter only if QML DBus binding proves too expensive |
| Bluetooth | BlueZ DBus | BlueZ DBus |
| Battery | UPower DBus | read-only |
| Power profile | power-profiles-daemon DBus | DBus; fallback `powerprofilesctl` |
| Brightness | brightnessctl | debounced process adapter, then udev/DBus if needed |
| Night light | existing Hyprland/hyprsunset policy | one dedicated adapter |
| Notifications | QS notification server or existing Mako during migration | never run two notification daemons simultaneously |
| Media | MPRIS DBus / playerctl fallback | MPRIS DBus |
| Session actions | logind DBus | `loginctl` fallback only for actions requiring it |

Process calls must use argument arrays (`Process.command`), never shell-string concatenation with user data. Validate user-provided SSIDs and device identifiers before action.

---

## Scope and delivery order

Each phase must build, launch, and pass its acceptance test before next phase starts. Do not start full shell migration with an untested lockscreen.

### Phase 0 — Stabilize and prepare

**Goal:** leave desktop usable while QS is introduced.

1. Preserve existing `gtklock`, `hypridle`, Waybar, Mako, Wofi, and l1p0 menus.
2. Stop developing current WebKit/Lit control center. Replace it only when QS Control Centre reaches parity.
3. Add Quickshell Nix module and minimal `shell.qml` with a visible test surface.
4. Add one user service and `qs-shell` command.
5. Add a toggle keybinding that starts or communicates with QS via IPC, not `pgrep` path matching.

**Acceptance:** `qs-shell` launches once, survives Waybar restart, exits cleanly on logout, appears at correct scale on eDP-1/DP-10/DP-8, and does not replace existing UI.

### Phase 1 — Theme, shell state, primitives

**Goal:** establish visual system before product UI.

1. Generate QML palette and metrics from Nix theme values.
2. Implement `Surface`, `SvgButton`, `ToggleTile`, `LevelSlider`, `DeviceRow`, `StatusMessage`.
3. Implement overlay state: one active top-right overlay; Escape, click-away, and toggle key close it.
4. Implement reduced-motion state. Every animation reads this state.
5. Add keyboard focus rings, Tab traversal, Enter/Space activation, accessible names.

**Acceptance:** static component gallery works on every monitor, no raster assets or Nerd Font icons, zero visual jump when opening or closing overlays.

### Phase 2 — Audio and brightness quick controls

**Goal:** replace WebKit Sound widget with native QS reference-quality control.

1. Build compact right-edge Control Centre using Brain Shell’s audio/brightness interaction as inspiration: vertical sliders in compact mode, expanded detail sheet on click.
2. Implement `AudioService` with default sink/source, volume, mute, device list, output/input switch, and media metadata/playback when an MPRIS player exists.
3. Implement brightness slider with 50–100ms debounce. Read state at start and after writes; never optimistic-update permanently.
4. Add OSD for hardware volume and brightness keys.

**Acceptance:** changing volume via QS, hardware key, and `wpctl` stays synchronized; output/source switches work; 0%, mute, no-device, Bluetooth headset, and 150% volume states render correctly.

### Phase 3 — Network and Bluetooth

**Goal:** deliver functional quick settings, not decorative tiles.

1. Wi-Fi tile: radio toggle, active SSID, strength/security, scan, connect, disconnect, known network list, hidden SSID path, VPN status.
2. Bluetooth tile: adapter toggle, discovery, paired devices, connect/disconnect, forget pairing, battery where BlueZ exposes it.
3. Airplane mode must use rfkill only after checking existing modem/Wi-Fi policy.
4. Use detail sheet per feature; compact tile only presents current state + primary action.

**Acceptance:** actions reflect actual NetworkManager/BlueZ signals; failed auth/connect produces actionable error; Wi-Fi and Bluetooth unavailable/hardware-off states do not crash panel.

### Phase 4 — Battery, power, display, focus

**Goal:** match desktop quick settings expected on macOS-class UX with Linux equivalents.

1. Battery: percent, charging/discharging, time estimate, wattage, health if UPower/hardware exposes it.
2. Power profile segmented control: saver, balanced, performance.
3. Brightness and night-light controls integrate into Control Centre detail sheet.
4. Focus/DND: notification state, duration choices, visual active state.
5. Add per-device battery rows for headset/mouse where BlueZ exposes data.

**Acceptance:** state stays correct after lid close, AC plug/unplug, profile changes outside QS, and DND changes from notification service.

### Phase 5 — Notification centre and media

**Goal:** replace Mako only when QS notification handling is reliable.

1. Implement a notification daemon/service or deliberately keep Mako and consume its history through documented IPC. Pick one; never race two servers.
2. Notification centre: grouped history, clear, per-app actions, DND.
3. Persistent media card: artwork, title/artist, play/pause, previous/next, seek.
4. Clipboard history remains Cliphist initially; do not fold it into QS until notification centre is stable.

**Acceptance:** notification actions work; urgency and DND semantics preserved; no duplicate toasts; media survives player restart.

### Phase 6 — Launcher and session menu

**Goal:** remove Wofi only after search quality is good.

1. App launcher indexes `.desktop` files, matches keywords/categories, keyboard navigation, launch failures, recent apps later.
2. Session menu: lock, suspend, hibernate where supported, logout, reboot, power off; confirmation for destructive actions.
3. Keep Wofi as fallback command for one release cycle.

**Acceptance:** all actions use logind/polkit safely; launcher opens keyboard-first; fallback remains reachable from a terminal/keybind.

### Phase 7 — Quickshell lockscreen

**Goal:** replace GTKLock only after security and recovery testing.

1. Build Qylock-inspired `LockScreen.qml`: wallpaper/dim layer, clear clock, central auth island, status text, optional media, restrained animation.
2. Use `WlSessionLock` on every output. No ordinary overlay/window is acceptable as a lock.
3. Create explicit PAM service `quickshell-lock`:

```pam
auth sufficient pam_fprintd.so max-tries=3 timeout=30
auth sufficient pam_unix.so likeauth try_first_pass
auth required pam_deny.so

account required pam_unix.so
session required pam_unix.so
```

4. `AuthenticationService` must handle PAM prompt, success, failure, cancellation, fingerprint wait, timeout, and password fallback.
5. Keep GTKLock bound as recovery path until QS lock passes tests. Never delete GTKLock before physical testing.
6. Make lock command idempotent; repeated calls must focus existing lock, not create competing sessions.
7. Power actions inside lock use logind and remain subject to current polkit policy.

**Required manual test matrix:** password unlock; enrolled right-thumb fingerprint unlock; failed fingerprint -> password fallback; incorrect password -> visible error and retry; `SUPER+CTRL+L`; idle timeout; `loginctl lock-session`; suspend/resume; lid close/resume; docked triple-display; undocked laptop; portrait DP-8; external display unplug while locked; VT switch/return; QS process-kill recovery.

**Acceptance:** every test passes on hardware. Only then point `hypridle.lock_cmd` and `SUPER+CTRL+L` at `qs-lock`; remove GTKLock after one further week of daily use.

### Phase 8 — Remove replaced tools and harden

Remove a legacy tool only after its QS replacement passes matching acceptance checks:

| Remove | Only after |
|---|---|
| WebKit/Lit control centre | QS audio/brightness + network/Bluetooth work |
| l1p0 menus | QS quick controls cover audio, network, Bluetooth, battery, brightness |
| Waybar | QS top bar, workspace handling, tray, and multi-monitor behavior work |
| Mako | QS notification service/history/DND works |
| Wofi | QS launcher works and fallback period completes |
| GTKLock | QS lock test matrix and recovery period pass |

Then remove obsolete packages, commands, keybindings, and user services in same commit as replacement activation. Do not leave duplicate overlays competing for clicks.

---

## Hyprland integration

Files to update deliberately:

- `home/lawliet.nix`: import QS module.
- `modules/home/desktop/hyprland.nix`: point keybinds/exec-once to QS IPC commands only after each replacement phase.
- `modules/home/desktop/waybar.nix`: retain during migration, then replace progressively.
- `modules/home/desktop/hyprlock.nix`: keep as reference/recovery only; current active lock is GTKLock.
- `modules/nixos/gtklock.nix`: retain until Phase 7 passes.
- `modules/nixos/security.nix`: add `quickshell-lock` PAM service only in Phase 7.

Existing monitor topology is authoritative:

- eDP-1: scale 1.5, 2880×1800
- DP-10 Lenovo: landscape, main display
- DP-8 AOC: transform 270, portrait

All QS windows bind to focused/selected screen and derive dimensions from its logical size. Do not assume connector order or a fixed 1920×1080 coordinate plane.

---

## Testing and observability

### Build checks per change

```sh
nix-instantiate --parse modules/home/desktop/quickshell.nix
nixos-rebuild build --flake /etc/nixos#casino
git diff --check
```

For QML, add a development command that runs source with a separate config/runtime identifier. Never test an unreviewed lockscreen against live session first.

### Runtime checks

- user service: `systemctl --user status quickshell-lawliet`;
- logs: `journalctl --user -u quickshell-lawliet -b`;
- use QS logging categories for services and overlays;
- no silent error swallowing around DBus/process calls;
- show short user-readable errors in UI, detailed errors in journal.

### Performance budget

- no continuous one-second polling for state available through DBus/PipeWire signals;
- debounce slider writes;
- unload expensive detail views while closed;
- do not decode video lockscreen backgrounds unless measured acceptable on battery;
- verify idle CPU before/after every added service.

---

## Commit plan

1. `feat(shell): add isolated quickshell runtime`
2. `feat(shell): add generated theme primitives`
3. `feat(shell): add audio and brightness quick controls`
4. `feat(shell): add network and bluetooth controls`
5. `feat(shell): add battery power and focus controls`
6. `feat(shell): add notification centre and media`
7. `feat(shell): add launcher and session menu`
8. `feat(shell): add session-locked QML lockscreen`
9. `refactor(shell): retire replaced legacy overlays`

Never mix workstation changes, photo tooling, Blender pinning, greetd work, or display-layout changes into these commits.

---

## Definition of done

Done only when:

- QS owns listed overlays without duplicate legacy processes;
- audio, Wi-Fi, Bluetooth, battery, power profiles, brightness, DND, notifications, media, launcher, and session actions function;
- every widget has loading, unavailable, error, and active states;
- native SVG icons render at every scale;
- eDP-1, DP-10, DP-8, dock/undock, portrait rotation, and reduced motion work;
- lockscreen test matrix passes, including fingerprint + password fallback;
- old tools are removed only after replacement stability;
- full Nix build succeeds from clean checkout.

## Explicit non-goals

- Replace Hyprland compositor.
- Replace greetd/ReGreet login screen in this phase.
- Copy proprietary fonts/assets or upstream source without license review.
- Pretend Apple-specific systems (AirDrop, iCloud, Continuity) exist on Linux.
- Add every full-shell feature before core controls and lock safety work.
`