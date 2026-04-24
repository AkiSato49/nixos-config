{ config, pkgs, ... }:

{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label   = "lock";
        action  = "hyprlock";
        text    = "󰌾\nlock";
        keybind = "l";
      }
      {
        label   = "hibernate";
        action  = "systemctl hibernate";
        text    = "󰒳\nhibernate";
        keybind = "h";
      }
      {
        label   = "logout";
        action  = "hyprctl dispatch exit";
        text    = "󰍃\nlogout";
        keybind = "e";
      }
      {
        label   = "shutdown";
        action  = "systemctl poweroff";
        text    = "󰐥\nshutdown";
        keybind = "s";
      }
      {
        label   = "suspend";
        action  = "systemctl suspend";
        text    = "󰒲\nsuspend";
        keybind = "u";
      }
      {
        label   = "reboot";
        action  = "systemctl reboot";
        text    = "󰑐\nreboot";
        keybind = "r";
      }
    ];

    style = ''
      * {
        background-image: none;
        font-family: "JetBrainsMono Nerd Font";
        box-shadow: none;
      }

      window {
        background-color: rgba(29, 32, 33, 0.93);
      }

      button {
        color: #928374;
        background-color: rgba(40, 40, 40, 0.6);
        border: 1px solid #3c3836;
        border-radius: 4px;
        margin: 16px;
        padding: 32px 52px;
        font-size: 18px;
        letter-spacing: 0.12em;
        text-align: center;
        transition: color 0.15s ease,
                    border-color 0.15s ease,
                    background-color 0.15s ease;
      }

      button:hover {
        color: #d79921;
        background-color: rgba(55, 50, 45, 0.8);
        border-color: #d79921;
      }

      #shutdown:hover {
        color: #fb4934;
        border-color: #cc241d;
        background-color: rgba(204, 36, 29, 0.12);
      }

      #reboot:hover {
        color: #fabd2f;
        border-color: #d79921;
        background-color: rgba(215, 153, 33, 0.1);
      }
    '';
  };
}
