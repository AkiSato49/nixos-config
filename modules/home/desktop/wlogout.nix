{ config, pkgs, theme, ... }:
let
  c       = theme.colors;
  useText = theme.variants.wlogout_text;

  # ── Text layout (prayer theme) ───────────────────────────────────────────────
  textLayout = [
    { label = "lock";      action = "hyprlock";              text = "LOCK";      keybind = "l"; }
    { label = "hibernate"; action = "systemctl hibernate";   text = "HIBERNATE"; keybind = "h"; }
    { label = "logout";    action = "hyprctl dispatch exit"; text = "LOGOUT";    keybind = "e"; }
    { label = "shutdown";  action = "systemctl poweroff";    text = "SHUTDOWN";  keybind = "s"; }
    { label = "suspend";   action = "systemctl suspend";     text = "SUSPEND";   keybind = "u"; }
    { label = "reboot";    action = "systemctl reboot";      text = "REBOOT";    keybind = "r"; }
  ];

  # ── Icon layout (dark theme) ─────────────────────────────────────────────────
  iconLayout = [
    { label = "lock";      action = "hyprlock";              text = "󰌾"; keybind = "l"; }
    { label = "hibernate"; action = "systemctl hibernate";   text = "󰒳"; keybind = "h"; }
    { label = "logout";    action = "hyprctl dispatch exit"; text = "󰍃"; keybind = "e"; }
    { label = "shutdown";  action = "systemctl poweroff";    text = "󰐥"; keybind = "s"; }
    { label = "suspend";   action = "systemctl suspend";     text = "󰒲"; keybind = "u"; }
    { label = "reboot";    action = "systemctl reboot";      text = "󰑐"; keybind = "r"; }
  ];

  # ── Pure text style (prayer) — no blocks, just floating text on dark overlay
  textStyle = ''
    * {
      font-family: "${theme.font.ui}";
      background-image: none;
      box-shadow: none;
      border: none;
      outline: none;
    }

    window {
      background-color: rgba(29, 32, 33, 0.88);
    }

    box { background: transparent; }

    button {
      all: unset;
      color: ${c.fg_muted};
      font-family: "${theme.font.ui}";
      font-size: 80px;
      letter-spacing: 0.08em;
    }

    button:hover,
    button:focus,
    button:active {
      all: unset;
      font-family: "${theme.font.ui}";
      font-size: 80px;
      letter-spacing: 0.08em;
    }

    #lock:hover      { color: ${c.yellow}; }
    #hibernate:hover { color: ${c.blue_br}; }
    #logout:hover    { color: ${c.fg}; }
    #shutdown:hover  { color: ${c.red_br}; }
    #suspend:hover   { color: ${c.blue_br}; }
    #reboot:hover    { color: ${c.teal_br}; }
  '';

  # ── Icon style (dark theme) ──────────────────────────────────────────────────
  iconStyle = ''
    * {
      background-image: none;
      background-color: transparent;
      font-family: "${theme.font.ui}";
      box-shadow: none;
      border: none;
      outline: none;
    }

    window {
      background-color: rgba(29, 32, 33, 0.95);
    }

    box { background-color: transparent; }

    button {
      color: ${c.fg_muted};
      background-color: rgba(40, 40, 40, 0.7);
      border: 1px solid ${c.bg1} !important;
      border-radius: 6px;
      margin: 20px;
      padding: 48px 36px;
      font-size: 192px;
      letter-spacing: 0.08em;
      transition: color 0.15s ease,
                  border-color 0.15s ease,
                  background-color 0.15s ease;
    }

    button:hover {
      color: ${c.yellow};
      background-color: rgba(60, 56, 54, 0.8);
      border-color: ${c.yellow} !important;
    }

    #shutdown:hover {
      color: ${c.red_br};
      border-color: ${c.red} !important;
      background-color: rgba(204, 36, 29, 0.12);
    }

    #reboot:hover {
      color: ${c.yellow_br};
      border-color: ${c.yellow} !important;
      background-color: rgba(215, 153, 33, 0.08);
    }
  '';
in {
  programs.wlogout = {
    enable = true;
    layout = if useText then textLayout else iconLayout;
    style  = if useText then textStyle  else iconStyle;
  };
}
