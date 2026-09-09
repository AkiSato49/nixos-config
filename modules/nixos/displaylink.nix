{ config, pkgs, ... }:

let
  # Hyprland launcher that picks the correct DRM devices for DisplayLink/evdi.
  # Aquamarine (Hyprland's render backend) needs AQ_DRM_DEVICES pointing at the
  # primary GPU first, with the evdi card appended — otherwise the DisplayLink
  # output stays black even though the kernel sees the monitor.
  hyprland-displaylink = pkgs.writeShellScriptBin "hyprland-displaylink" ''
    set -u

    primary=""
    evdi=""
    others=()

    for card in /dev/dri/card*; do
      [ -e "$card" ] || continue
      sys="/sys/class/drm/$(basename "$card")/device"
      driver=""
      if [ -L "$sys/driver" ]; then
        driver="$(basename "$(readlink -f "$sys/driver")")"
      fi
      case "$driver" in
        evdi)                 evdi="$card" ;;
        i915|xe|amdgpu|nvidia|nvidia-drm)
                              [ -z "$primary" ] && primary="$card" || others+=("$card") ;;
        *)                    others+=("$card") ;;
      esac
    done

    devs=""
    [ -n "$primary" ] && devs="$primary"
    for o in "''${others[@]}"; do
      devs="''${devs:+$devs:}$o"
    done
    [ -n "$evdi" ] && devs="''${devs:+$devs:}$evdi"

    if [ -n "$devs" ]; then
      export AQ_DRM_DEVICES="$devs"
    fi

    echo "hyprland-displaylink: AQ_DRM_DEVICES=''${AQ_DRM_DEVICES:-<unset>}" >&2
    exec start-hyprland "$@"
  '';
in
{
  # DisplayLink USB dock support.
  #
  # The DisplayLink dock presents an EVDI virtual GPU. The userspace
  # DisplayLinkManager daemon (`dlm`) reads frames from evdi and pushes them
  # over USB to the dock. On Wayland/Hyprland we additionally need to tell
  # Aquamarine to enumerate the evdi card via AQ_DRM_DEVICES — see the wrapper
  # above and modules/nixos/greetd.nix.
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  # evdi kernel module (matched to the running kernel).
  boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
  boot.kernelModules       = [ "evdi" ];

  # Userspace bits + udev rules so dlm starts when the dock is plugged in.
  # Launcher is exposed system-wide so greetd can find it.
  services.udev.packages     = [ pkgs.displaylink ];
  environment.systemPackages = [ pkgs.displaylink hyprland-displaylink ];

  # Noctalia Greeter discovers sessions through Wayland desktop entries. Keep
  # its greetd command untouched; this wrapper remains available for an
  # explicit DisplayLink-aware Hyprland session entry when needed.
}
