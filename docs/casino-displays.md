# casino — Triple Monitor Setup

Laptop (`casino`) drives three displays:

| Output    | Connector                       | Panel                | Notes                       |
|-----------|---------------------------------|----------------------|-----------------------------|
| `eDP-1`   | Internal                        | 2880×1800 @ 60 Hz    | HiDPI, scale 1.5            |
| `HDMI-A-1`| Native HDMI                     | 2560×1440 @ 60 Hz    | scale 1                     |
| `DVI-I-1` | DisplayLink USB dock → DVI      | 2560×1440 @ 60 Hz    | scale 1, rotated 270° (portrait) |

Layout (left → right): `eDP-1` | `HDMI-A-1` | `DVI-I-1` (portrait).

Configured in `modules/home/desktop/hyprland.nix` (`monitor =` lines).

## DisplayLink (DVI output)

The dock isn't a real GPU. Linux exposes it as an `evdi` virtual DRM card,
and the userspace `DisplayLinkManager` daemon (`dlm`) reads frames out of
evdi and pushes them over USB to the dock.

Three things must be true for the DisplayLink output to come up:

1. **`evdi` kernel module loaded** — `boot.kernelModules = [ "evdi" ]`
   plus `boot.extraModulePackages = [ kernelPackages.evdi ]` (matched to
   the running kernel).
2. **`dlm` running** — pulled in by
   `services.xserver.videoDrivers = [ "displaylink" "modesetting" ]`,
   together with the `displaylink` package and its udev rules.
3. **Hyprland told to use the evdi card** — Aquamarine (Hyprland's
   render backend) only enumerates the first DRM card it finds unless
   `AQ_DRM_DEVICES` is set. Without it the monitor stays completely
   black even though `hyprctl monitors` may list it.

All of this lives in `modules/nixos/displaylink.nix`. That module also
ships a `hyprland-displaylink` wrapper that:

- scans `/dev/dri/card*`,
- puts the iGPU/dGPU first (`i915`/`xe`/`amdgpu`/`nvidia`),
- appends the `evdi` card last,
- exports `AQ_DRM_DEVICES=...` and `exec`s `Hyprland`.

The module force-overrides `services.greetd.settings.default_session.command`
to launch via this wrapper, so the env var is set *before* the compositor
starts. Mambo doesn't import `displaylink.nix`, so it keeps the plain
`Hyprland` command from `modules/nixos/greetd.nix`.

### Debugging a dark DisplayLink output

```
# kernel sees the dock?
lsmod | grep evdi
ls -l /dev/dri/                # expect a card with driver -> evdi
udevadm info /dev/dri/cardN | grep DRIVER

# dlm running?
systemctl status dlm

# Hyprland actually got the card?
hyprctl monitors all
echo "$AQ_DRM_DEVICES"         # inside the Hyprland session
journalctl --user -u hyprland-session.target -b | grep -i aq
```

If `hyprctl monitors all` lists `DVI-I-1` but it's black, `AQ_DRM_DEVICES`
is almost certainly missing or has the cards in the wrong order — the
evdi card must come *after* the primary GPU.

If `DVI-I-1` is missing entirely, it's a kernel/dlm problem: replug,
check `dmesg | grep -i evdi`, and verify `dlm` is running.

## Wallpapers

Per-monitor wallpapers are managed by `hyprpaper`
(`modules/home/desktop/hyprpaper.nix`).

Two scripts ship with the module:

- `set-wallpaper <image>` — slices a single source image into three
  monitor-shaped tiles via ImageMagick, writes them to
  `~/Pictures/wallpapers/{edp1,hdmi,dvi}.png`, and applies them via
  `hyprctl hyprpaper`.
- `set-wallpaper-apply` — re-applies whatever's already in
  `~/Pictures/wallpapers/`. Runs at login from `exec-once` in
  `hyprland.nix`.

**Path is case-sensitive and lowercase: `~/Pictures/wallpapers/`.**
An earlier version of `hyprpaper.nix` mixed `Wallpapers/` (capital W,
in the static `preload`/`wallpaper` settings) with `wallpapers/`
(lowercase, in the scripts). The static config silently failed to
preload missing files, which is why HDMI showed up with no background
while the others worked — `set-wallpaper-apply` only re-applies if it
finds `edp1.png`, and it doesn't fail loudly when `hdmi.png` is missing.

If a monitor still has no background after rebuild:

```
ls ~/Pictures/wallpapers/      # expect edp1.png, hdmi.png, dvi.png
set-wallpaper ~/Pictures/some-source.jpg
```

## Workspaces across monitors

Workspaces are **not** statically pinned in the Hyprland config.
`assign-ws` (in `modules/home/desktop/hyprland.nix`) runs at login and
on every `monitoradded` / `monitorremoved` event from Hyprland's
`socket2`, distributing 10 workspaces as evenly as possible across
whatever's currently connected:

| Monitors | Distribution     |
|----------|------------------|
| 1        | 10               |
| 2        | 5 / 5            |
| 3        | 4 / 3 / 3        |
| 4        | 3 / 3 / 2 / 2    |
| n        | `ceil(10/n)` for the leftmost `10 mod n`, then `floor(10/n)` |

Monitors are sorted **left-to-right by physical X coordinate** before
assignment, so workspace 1 is always on the leftmost display, 10 on
the rightmost. Each monitor's first workspace is marked
`default:true`, so focusing a monitor lands on a sane workspace.

When a monitor disappears (undock, cable yanked, dock reboots),
`assign-ws` re-runs and `moveworkspacetomonitor` migrates any
workspaces that were on the dead output — windows are never
orphaned. When it reappears, workspaces redistribute again.

This means **`SUPER+1`..`SUPER+0` always work, on any host, with any
number of monitors connected**. The keybinds target workspace numbers,
not monitors, so the layout adapts automatically.

### Static monitor pinning (casino only)

On casino the three-display geometry is fixed in `hyprland.nix`:

```
eDP-1    : 2880x1800 / scale 1.5 -> 1920x1200 logical, at 0,0
HDMI-A-1 : 2560x1440 / scale 1   -> 2560x1440 logical, at 1920,0
DVI-I-1  : 2560x1440 / scale 1, transform 3 (270°) -> 1440x2560 at 4480,0
```

If any of those three are missing they're simply skipped — Hyprland
ignores `monitor =` lines for unconnected outputs. Anything *not*
listed (a random projector, a second HDMI etc.) falls through to the
catch-all `monitor = ,preferred,auto,1` rule and is auto-placed.

On mambo no monitors are pinned at all; the catch-all does everything,
so whatever you plug in just works.

`kanshi` (`modules/home/desktop/kanshi.nix`) handles dock/undock
profiles — currently only an `undocked` profile is defined; extend
with `docked`/`one_external`/etc. as needed.
