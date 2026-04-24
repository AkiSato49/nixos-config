{ config, pkgs, ... }:

{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label   = "lock";
        action  = "hyprlock";
        text    = "Lock";
        keybind = "l";
      }
      {
        label   = "hibernate";
        action  = "systemctl hibernate";
        text    = "Hibernate";
        keybind = "h";
      }
      {
        label   = "logout";
        action  = "hyprctl dispatch exit";
        text    = "Logout";
        keybind = "e";
      }
      {
        label   = "shutdown";
        action  = "systemctl poweroff";
        text    = "Shutdown";
        keybind = "s";
      }
      {
        label   = "suspend";
        action  = "systemctl suspend";
        text    = "Suspend";
        keybind = "u";
      }
      {
        label   = "reboot";
        action  = "systemctl reboot";
        text    = "Reboot";
        keybind = "r";
      }
    ];

    style = ''
      * {
        background-image: none;
        font-family: "JetBrainsMono Nerd Font";
      }

      window {
        background-color: rgba(29, 32, 33, 0.92);
      }

      button {
        color: #ebdbb2;
        background-color: #282828;
        border: 2px solid #3c3836;
        border-radius: 12px;
        margin: 8px;
        font-size: 16px;
        transition: background-color 0.2s ease, border-color 0.2s ease;
      }

      button:hover {
        background-color: #3c3836;
        border-color: #d79921;
        color: #d79921;
      }

      #lock    { border-image: none; }
      #logout  { border-image: none; }
      #suspend { border-image: none; }
      #hibernate { border-image: none; }
      #shutdown {
        border-image: none;
      }
      #shutdown:hover {
        border-color: #cc241d;
        color: #cc241d;
        background-color: rgba(204, 36, 29, 0.15);
      }
      #reboot {
        border-image: none;
      }
      #reboot:hover {
        border-color: #fabd2f;
        color: #fabd2f;
        background-color: rgba(250, 189, 47, 0.1);
      }
    '';
  };
}
