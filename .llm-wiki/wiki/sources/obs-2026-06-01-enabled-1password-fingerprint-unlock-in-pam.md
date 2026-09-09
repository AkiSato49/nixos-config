---
type: source
title: "Observation: Enabled 1Password fingerprint unlock in PAM"
slug: obs-2026-06-01-enabled-1password-fingerprint-unlock-in-pam
status: observation
created: 2026-06-01
updated: 2026-06-01
relevance: high
observed_at: 2026-06-01T03:54:20.312Z
tags: ["nixos", "security", "pam", "1password", "fprintd"]
source_context: "Configuring 1Password fingerprint authentication via PAM"
---
# ⭐ Observation: Enabled 1Password fingerprint unlock in PAM
Configured `security.pam.services.onepassword.fprintAuth = true;` in `/etc/nixos/modules/nixos/security.nix` to enable fingerprint/biometric unlocking for the 1Password GUI application on NixOS.
*Relevance: high*

*Context: Configuring 1Password fingerprint authentication via PAM*

*Tags: nixos security pam 1password fprintd*
---
*Observed: 2026-06-01T03:54:20.312Z*