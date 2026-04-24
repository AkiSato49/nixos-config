{ config, pkgs, ... }:

{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label   = "lock";
        action  = "hyprlock";
        text    = "󰌾";
        keybind = "l";
      }
      {
        label   = "hibernate";
        action  = "systemctl hibernate";
        text    = "󰒳";
        keybind = "h";
      }
      {
        label   = "logout";
        action  = "hyprctl dispatch exit";
        text    = "󰍃";
        keybind = "e";
      }
      {
        label   = "shutdown";
        action  = "systemctl poweroff";
        text    = "󰐥";
        keybind = "s";
      }
      {
        label   = "suspend";
        action  = "systemctl suspend";
        text    = "󰒲";
        keybind = "u";
      }
      {
        label   = "reboot";
        action  = "systemctl reboot";
        text    = "󰑐";
        keybind = "r";
      }
    ];

    style = ''
      * {
        background-image: none;
        background-color: transparent;
        font-family: "JetBrainsMono Nerd Font";
        box-shadow: none;
        border: none;
        outline: none;
      }

      window {
        background-color: rgba(29, 32, 33, 0.95);
      }

      box {
        background-color: transparent;
      }

      button {
        color: #665c54;
        background-color: rgba(40, 40, 40, 0.7);
        border: 1px solid #3c3836 !important;
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
        color: #d79921;
        background-color: rgba(60, 56, 54, 0.8);
        border-color: #d79921 !important;
      }

      #shutdown:hover {
        color: #fb4934;
        border-color: #cc241d !important;
        background-color: rgba(204, 36, 29, 0.12);
      }

      #reboot:hover {
        color: #fabd2f;
        border-color: #d79921 !important;
        background-color: rgba(215, 153, 33, 0.08);
      }
    '';
  };
}
