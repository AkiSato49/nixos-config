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
        background-color: rgba(29, 32, 33, 0.93);
      }

      button {
        color: #665c54;
        background-color: transparent;
        border: 1px solid #3c3836;
        border-radius: 4px;
        margin: 12px;
        font-size: 11px;
        letter-spacing: 0.15em;
        text-transform: uppercase;
        transition: color 0.15s ease, border-color 0.15s ease, background-color 0.15s ease;
      }

      button:hover {
        color: #ebdbb2;
        background-color: #282828;
        border-color: #504945;
      }

      /* Icons via ::before — large, above label */
      button::before {
        font-size: 28px;
        display: block;
        margin-bottom: 8px;
        letter-spacing: 0;
        text-transform: none;
      }

      #lock::before     { content: "󰌾"; }
      #logout::before   { content: "󰍃"; }
      #suspend::before  { content: "󰒲"; }
      #hibernate::before { content: "󰒳"; }
      #shutdown::before { content: "󰐥"; }
      #reboot::before   { content: "󰑐"; }

      #shutdown:hover {
        color: #cc241d;
        border-color: #cc241d;
        background-color: rgba(204, 36, 29, 0.08);
      }

      #reboot:hover {
        color: #fabd2f;
        border-color: #fabd2f;
        background-color: rgba(250, 189, 47, 0.06);
      }

      #lock:hover, #logout:hover, #suspend:hover, #hibernate:hover {
        color: #d79921;
        border-color: #d79921;
      }
    '';
  };
}
