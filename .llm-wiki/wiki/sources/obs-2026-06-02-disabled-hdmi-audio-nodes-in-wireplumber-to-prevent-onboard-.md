---
type: source
title: "Observation: Disabled HDMI audio nodes in WirePlumber to prevent onboard audio dropout on dock connection"
slug: obs-2026-06-02-disabled-hdmi-audio-nodes-in-wireplumber-to-prevent-onboard-
status: observation
created: 2026-06-02
updated: 2026-06-02
relevance: high
observed_at: 2026-06-02T03:52:39.648Z
tags: ["nixos", "audio", "wireplumber", "dock"]
source_context: "Fixing laptop speakers and microphone disappearing when dock connected"
---
# ⭐ Observation: Disabled HDMI audio nodes in WirePlumber to prevent onboard audio dropout on dock connection
Added WirePlumber configuration rule to disable PCI HDMI audio nodes under services.pipewire.wireplumber.extraConfig in modules/nixos/audio.nix. This prevents the HDA Intel/AMD card from switching profiles from Analog Duplex (speakers/mic) to HDMI outputs when the dock is connected, preventing onboard audio from disappearing.
*Relevance: high*

*Context: Fixing laptop speakers and microphone disappearing when dock connected*

*Tags: nixos audio wireplumber dock*
---
*Observed: 2026-06-02T03:52:39.648Z*