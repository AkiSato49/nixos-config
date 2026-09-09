---
type: source
title: "Observation: Enabled automatic keyring unlock in PAM configuration"
slug: obs-2026-06-01-enabled-automatic-keyring-unlock-in-pam-configuration
status: observation
created: 2026-06-01
updated: 2026-06-01
relevance: high
observed_at: 2026-06-01T02:00:34.268Z
tags: ["nixos", "security", "pam", "keyring", "greetd"]
source_context: "Fixing automatic gnome-keyring unlocking via PAM"
---
# ⭐ Observation: Enabled automatic keyring unlock in PAM configuration
Identified that GNOME Keyring was not automatically unlocking on login because PAM services `login` and `greetd` did not have `enableGnomeKeyring = true;` configured. Enabled these options in /etc/nixos/modules/nixos/security.nix to fix the "keyring did not load" issue.
*Relevance: high*

*Context: Fixing automatic gnome-keyring unlocking via PAM*

*Tags: nixos security pam keyring greetd*
---
*Observed: 2026-06-01T02:00:34.268Z*