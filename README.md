# nixos-config 🪨

lawliet's NixOS flake configuration. Optimized for a clean, Swiss-grid aesthetic (0 rounding, no blur, high typography contrast) across laptop and desktop hosts. Powered by **Hyprland**, **Home Manager**, and **Ungoogled-Chromium**.

---

## 💻 Hosts

*   **`casino`** (Laptop): NixOS unstable, high-DPI scaling, power management (`power.nix`), and local obs setup.
*   **`mambo`** (Desktop): Ryzen 5 5600X + RTX 3070 Ti, custom NVIDIA drivers, OpenClaw, and the `home-utility-fetchers` service.

---

## 📂 Repository Structure

```
/etc/nixos/
├── flake.nix                       # Flake inputs, overlays, and host declarations (casino/mambo)
├── hosts/
│   ├── casino/                     # Laptop configuration
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── mambo/                      # Desktop configuration (RTX 3070 Ti)
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── nixos/                      # System-level modules
│   │   ├── profiles/
│   │   │   └── desktop.nix         # Consolidated shared workstation profile (Audio, Fonts, Nix-LD, etc.)
│   │   ├── audio.nix               # Pipewire + WebRTC automatic echo-cancellation & noise-suppression
│   │   ├── bluetooth.nix
│   │   ├── boot.nix                # Quiet boot parameters + latest kernel
│   │   ├── flatpak.nix
│   │   ├── fonts.nix
│   │   ├── greetd.nix              # TUI greeter matching active theme
│   │   ├── home-utility-fetchers.nix # Automated daily billing cron (mambo only)
│   │   ├── mongodb.nix             # Local database service
│   │   ├── networking.nix          # ModemManager + OpenSSH + Syncthing
│   │   ├── nix-ld.nix              # Dynamic linker helper for un-patched binaries
│   │   ├── security.nix            # 1Password, Docker, and PAM fprintd settings
│   │   └── tailscale.nix           # Tailscale client + auto-persisting Taildrive mounter
│   └── home/                       # Home-Manager user modules
│       ├── desktop/
│       │   ├── hyprland.nix        # Window manager configuration + workspace assignments
│       │   ├── hyprpaper.nix       # Wallpaper definitions
│       │   ├── hyprlock.nix        # Lock screen + hypridle timeouts + active fingerprint polling
│       │   ├── waybar.nix          # Custom Waybar status bar (patched Alexays version)
│       │   ├── mako.nix            # Dunst-like desktop notifications
│       │   ├── wofi.nix            # Crisp application launcher
│       │   ├── theming.nix         # Unified GTK/QT themes and Bibata cursors
│       │   └── kanshi.nix          # Hot-plug multi-monitor layouts
│       ├── shell/
│       │   ├── zsh.nix             # Zsh settings + minimal Starship prompt
│       │   └── tools.nix           # Modern CLI utilities (eza, bat, fd, rg, lazygit)
│       ├── apps/
│       │   ├── alacritty.nix       # Terminal emulator (primary, Super+C/V copy-paste enabled)
│       │   ├── helium.nix          # Custom AppImage wrapper for Helium Browser (0.12.4.1)
│       │   ├── neovim.nix          # Native LazyVim configuration (Mason bypassed for Nix)
│       │   └── media.nix           # MPV, IMV, Zathura, and MIME type associations
│       └── dev/
│           ├── default.nix         # Development packages, compiler runtimes, and mise
│           └── pi.nix              # Pi agent development environment
└── home/
    └── lawliet.nix                 # Entrypoint user package list + conflict-clearance script
```

---

## 🛠️ Key Custom Automations

### 1. Smart Clipboard Handler (`smart-clipboard`)
Bound globally to `$mod+C` and `$mod+V`. Automatically detects active window state:
*   **Terminal (Alacritty)**: Dynamically routes actions as Wayland native `CTRL_SHIFT+C`/`V` shortcuts via Hyprland's `sendshortcut` dispatcher.
*   **Other Apps**: Emits standard clipboard `CTRL+C`/`V` triggers. Prevents physical modifier locks (no keyboard interrupt glitches).

### 2. Native Helium Browser Packaging
Wrapped via `appimageTools.wrapType2` to cleanly integrate the latest upstream AppImage release of **Helium Browser** directly into desktop applications menus, handling library requirements and desktop launchers natively.

### 3. Desktop Profile Consolidation
To prevent code duplication, a shared `/modules/nixos/profiles/desktop.nix` unifies all base workstation systems. Hosts simply import this single profile alongside hardware-specific overrides (e.g., `nvidia.nix` vs `power.nix`).

### 4. Active Fingerprint Unlocking
System PAM parameters are pre-configured to handle `fprintd` with a 5-second timeout, falling back smoothly to password auth. Hyprlock is configured with native `auth.fingerprint.enabled = true` to actively trigger the sensor on invocation.

---

## 🚀 Rebuild & Maintenance

These utility aliases are built into your shell:

| Alias | Command | Description |
| :--- | :--- | :--- |
| `rebuild` | `sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)` | Rebuild current host from local directory |
| `test-rebuild` | `sudo nixos-rebuild test --flake /etc/nixos#$(hostname)` | Dry-run trial of config changes without activation |
| `update` | `nix flake update --flake /etc/nixos && rebuild` | Fetch latest flake inputs and rebuild system |
| `cleanup` | `sudo nix-collect-garbage -d && sudo nix-store --optimise` | Empty trash generations and hardlink identical store entries |
| `lg` | `lazygit` | Git terminal dashboard |
| `ll` | `eza -la --icons --git` | Detailed icons list |
