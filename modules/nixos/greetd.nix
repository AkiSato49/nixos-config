{ pkgs, theme, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --greeting '${theme.greetd.greeting}' --time-format '${theme.greetd.time_fmt}' --theme '${theme.greetd.theme_str}' --cmd start-hyprland";
        user    = "greeter";
      };
    };
  };

  # Suppress spurious getty errors on other TTYs
  systemd.services.greetd.serviceConfig = {
    Type             = "idle";
    StandardInput    = "tty";
    StandardOutput   = "tty";
    StandardError    = "journal";
    TTYReset         = true;
    TTYVHangup       = true;
    TTYVTDisallocate = true;
  };
}
