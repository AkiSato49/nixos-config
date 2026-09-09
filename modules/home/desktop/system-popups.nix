{ lib, pkgs, theme, hostName ? "", ... }:

let
  c = theme.colors;
  g = theme.geometry;
  topMargin = if hostName == "casino" then 54 else 46;

  systemPopups = pkgs.python3Packages.buildPythonApplication {
    pname = "l1p0-menus";
    version = "2.0.0";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "L1p0-M";
      repo = "l1p0-menus";
      rev = "689376ce84b30c23ea4e2d2f227f765079bd5c5d";
      hash = "sha256-2t2A9DQrLEwYepnlfacS+BDp2Aqagfick0XqlfGR/7M=";
    };

    build-system = [ pkgs.python3Packages.hatchling ];
    dependencies = with pkgs.python3Packages; [ pygobject3 pulsectl ];
    nativeBuildInputs = [ pkgs.wrapGAppsHook4 pkgs.gobject-introspection ];
    buildInputs = [ pkgs.gtk4 pkgs.gtk4-layer-shell pkgs.libnotify pkgs.libsoup_3 ];

    # Upstream exposes Bluetooth inside network popup but omits direct CLI route.
    postPatch = ''
      substituteInPlace src/main.py \
        --replace-fail '"toggle_network": network' '"toggle_network": network,
        "toggle_bluetooth": network' \
        --replace-fail 'module.toggle_layer()' 'module.toggle_bluetooth_layer() if data == "toggle_bluetooth" else module.toggle_layer()' \
        --replace-fail '"audio", "brightness", "calendar", "battery", "network"' '"audio", "brightness", "calendar", "battery", "network", "bluetooth"'
      sed -i '/backdrop-filter: blur(10px);/d' src/assets/style.css

      cat >> src/popups/wifi.py <<'PY'

def toggle_bluetooth_layer():
    global _v_layer
    if _v_layer.get_visible():
        _v_layer.bluetoothtab.dbusbluez.discovery(False)
        _v_layer.hide()
    else:
        _v_layer.header_button.change_tab("Bluetooth-Tab")
        _v_layer.bluetoothtab.dbusbluez.discovery(True)
        _v_layer.show()
        _v_layer.present()
PY
    '';

    makeWrapperArgs = [
      "--prefix PATH : ${lib.makeBinPath [ pkgs.util-linux ]}"
      "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.gtk4-layer-shell ]}"
    ];

    meta = {
      description = "GTK4 dropdown controls for Waybar";
      homepage = "https://github.com/L1p0-M/l1p0-menus";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };
in {
  home.packages = [ systemPopups ];

  xdg.configFile."l1p0-menu/config.json".text = builtins.toJSON {
    audio = {
      anchor = "top-right";
      margin = "${toString topMargin}, 10";
    };
    network = {
      anchor = "top-right";
      margin = "${toString topMargin}, 10";
      notification = false;
    };
    battery = {
      anchor = "top-right";
      margin = "${toString topMargin}, 10";
      notification = false;
      notification_threshold = "3, 15, 20";
    };
    brightness = {
      anchor = "top-right";
      margin = "${toString topMargin}, 10";
      night_preset = "2500";
    };
  };

  xdg.configFile."l1p0-menu/style.css".text = ''
    * {
      font-family: "${theme.font.ui}";
      color: ${c.fg};
    }

    .audio-window,
    .brightness-window,
    .battery-window,
    .network-window {
      background: transparent;
    }

    .audio-layer,
    .brightness-layer,
    .battery-layer,
    .network-layer {
      min-width: 380px;
      background: ${c.bg_hard};
      border: ${toString g.border_size}px solid ${c.yellow};
      border-radius: ${toString g.rounding}px;
      padding: 16px;
    }

    .header {
      background: ${c.bg};
      border: 1px solid ${c.bg1};
      border-radius: ${toString g.rounding}px;
      padding: 3px;
    }

    button,
    .network-card,
    .saved-network-card,
    .power-profile-button,
    .floating-panel,
    .floating-panel-wifi,
    .audio-device-menu {
      color: ${c.fg};
      background: ${c.bg};
      border: 1px solid ${c.bg1};
      border-radius: ${toString g.rounding}px;
      box-shadow: none;
    }

    button {
      padding: 7px 10px;
    }

    button:hover,
    .header-button:hover,
    .network-card:hover,
    .saved-network-card:hover,
    .audio-device-button:hover {
      color: ${c.orange};
      background: ${c.bg1};
      border-color: ${c.yellow};
    }

    button:checked,
    .header-button.active,
    .header-button.active:hover,
    .network-card.active,
    .power-profile-button.active,
    .audio-device-button.active {
      color: ${c.bg_hard};
      background: ${c.yellow};
      border-color: ${c.yellow};
    }

    entry,
    .password-entry,
    .popup-entry {
      color: ${c.fg};
      background: ${c.bg};
      border: 1px solid ${c.bg1};
      border-radius: ${toString g.rounding}px;
      padding: 8px;
    }

    entry:focus,
    .password-entry:focus,
    .popup-entry:focus {
      border-color: ${c.yellow};
    }

    scale trough {
      min-height: 8px;
      background: ${c.bg1};
      border: none;
      border-radius: 999px;
    }

    scale highlight {
      min-height: 8px;
      background: ${c.yellow};
      border: none;
      border-radius: 999px;
      padding: 0;
    }

    scale slider {
      min-width: 16px;
      min-height: 16px;
      margin: -5px;
      background: ${c.bg_hard};
      border: 2px solid ${c.yellow};
      border-radius: 999px;
      box-shadow: none;
    }

    switch,
    .wifi-switch,
    .network-switch,
    .night-switch,
    .autoconnect-switch,
    .popup-switch {
      background: ${c.bg2};
      border-radius: 999px;
    }

    switch:checked,
    .wifi-switch:checked,
    .network-switch:checked,
    .night-switch:checked,
    .autoconnect-switch:checked,
    .popup-switch:checked {
      background: ${c.yellow};
    }

    switch slider {
      background: ${c.bg_hard};
      border: 1px solid ${c.bg2};
      border-radius: 999px;
      box-shadow: none;
    }

    .subname,
    .time-to,
    .popup-parameter,
    .combined-battery-status,
    .battery-rate {
      color: ${c.fg_muted};
    }

    .percent-text,
    .battery-level,
    .combined-battery-level,
    .popup-value {
      color: ${c.fg};
      font-weight: 700;
    }

    .error-not-found {
      color: ${c.red};
    }

    scrollbar slider {
      min-width: 5px;
      background: ${c.bg2};
      border-radius: 999px;
    }
  '';

  systemd.user.services.system-popups = {
    Unit = {
      Description = "Waybar system control dropdowns";
      After = [ "graphical-session.target" "waybar.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${systemPopups}/bin/l1p0-menus --daemon";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
