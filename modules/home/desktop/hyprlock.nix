{ config, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 5;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_size = 8;
          blur_passes = 2;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.4;
          vibrancy = 0.1;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(ebdbb2)";
          inner_color = "rgb(282828)";
          outer_color = "rgb(d79921)";
          outline_thickness = 2;
          placeholder_text = "<span foreground='##ebdbb2'>Password</span>";
          shadow_passes = 2;
          rounding = 8;
        }
      ];

      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b><big>$(date +"%H:%M")</big></b>"'';
          color = "rgba(ebdbb2ff)";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font Bold";
          position = "0, 160";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
        }
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
          color = "rgba(a89984ff)";
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 80";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };
      listener = [
        {
          timeout = 300; # 5 min — lock
          on-timeout = "hyprlock";
        }
        {
          timeout = 600; # 10 min — screen off
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
