---
type: source
title: "Observation: Enabled Waybar systemd service with auto-restart on Hyprland"
slug: obs-2026-06-02-enabled-waybar-systemd-service-with-auto-restart-on-hyprland
status: observation
created: 2026-06-02
updated: 2026-06-02
relevance: high
observed_at: 2026-06-02T05:42:43.021Z
tags: ["nixos", "waybar", "hyprland", "systemd"]
source_context: "Fixing Waybar crashing/dying after sleep/suspend"
---
# ⭐ Observation: Enabled Waybar systemd service with auto-restart on Hyprland
Configured wayland.windowManager.hyprland.systemd.enable = true and programs.waybar.systemd.enable = true. Added systemd.user.services.waybar service config override to set Restart=always and RestartSec=2. Removed exec-once=waybar from modules/home/desktop/hyprland.nix. This ensures Waybar restarts immediately if it crashes during suspend or DPMS/wake events.
*Relevance: high*

*Context: Fixing Waybar crashing/dying after sleep/suspend*

*Tags: nixos waybar hyprland systemd*
---
*Observed: 2026-06-02T05:42:43.021Z*