# nixos-config 🪨

lawliet's NixOS flake — gruvbox, hyprland, and everything needed.

## Structure

```
nixos-config/
├── flake.nix                    # inputs + outputs
├── hosts/
│   └── nixos/
│       ├── default.nix          # host config (users, nix settings, imports)
│       └── hardware-configuration.nix  # ← REPLACE WITH YOUR OWN
├── modules/
│   ├── nixos/                   # system-level modules
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── audio.nix
│   │   ├── bluetooth.nix
│   │   ├── fonts.nix
│   │   ├── flatpak.nix
│   │   ├── power.nix
│   │   └── security.nix
│   └── home/                    # home-manager modules
│       ├── desktop/
│       │   ├── hyprland.nix     # wm + keybinds
│       │   ├── hyprpaper.nix    # wallpaper
│       │   ├── hyprlock.nix     # lock screen + idle
│       │   ├── waybar.nix       # status bar
│       │   ├── mako.nix         # notifications
│       │   ├── wofi.nix         # launcher
│       │   ├── theming.nix      # gtk + qt + cursor
│       │   └── kanshi.nix       # multi-monitor profiles
│       ├── shell/
│       │   ├── zsh.nix          # shell + aliases + starship
│       │   └── tools.nix        # cli tools + git + fzf + bat
│       ├── apps/
│       │   ├── alacritty.nix    # terminal
│       │   ├── neovim.nix       # editor (lazy.nvim + gruvbox)
│       │   └── media.nix        # mpv + zathura + mime types
│       └── dev/
│           └── default.nix      # dev tools + runtimes
└── home/
    └── lawliet.nix              # user home-manager entrypoint
```

## First Time Install

### 1. Boot NixOS installer and partition your disk

### 2. Mount partitions
```bash
mount /dev/your-root /mnt
mount /dev/your-efi /mnt/boot
```

### 3. Generate hardware config
```bash
sudo nixos-generate-config --root /mnt
```

### 4. Clone this repo
```bash
nix-shell -p git
git clone https://github.com/AkiSato49/nixos-config /mnt/etc/nixos
```

### 5. Replace hardware-configuration.nix
```bash
cp /mnt/etc/nixos-generated/hardware-configuration.nix \
   /mnt/etc/nixos/hosts/nixos/hardware-configuration.nix
```

### 6. Install
```bash
sudo nixos-install --flake /mnt/etc/nixos#NixOS
```

### 7. Reboot and enjoy

---

## After Install

Move the config to your home dir:
```bash
mkdir -p ~/.config
mv /etc/nixos ~/nixos-config
ln -s ~/nixos-config /etc/nixos
```

## Useful Aliases (built into zsh)

| Alias | Command |
|---|---|
| `rebuild` | `sudo nixos-rebuild switch --flake ~/.config/nixos#NixOS` |
| `update` | `nix flake update && rebuild` |
| `cleanup` | `sudo nix-collect-garbage -d` |
| `lg` | lazygit |
| `ll` | eza -la --icons |

## Multi-Monitor Setup

After first boot, run `hyprctl monitors` to get your monitor IDs,
then fill them in at `modules/home/desktop/kanshi.nix`.

## Wallpaper

Drop a wallpaper at `~/.config/hypr/wallpaper.jpg` and update
`modules/home/desktop/hyprpaper.nix` with the path.
