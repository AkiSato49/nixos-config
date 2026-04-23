{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --greeting 'welcome back' --cmd start-Hyprland";
        user = "greeter";
      };
    };
  };

  # Suppress spurious getty errors on other TTYs
  systemd.services.greetd.serviceConfig = {
    Type            = "idle";
    StandardInput   = "tty";
    StandardOutput  = "tty";
    StandardError   = "journal";
    TTYReset        = true;
    TTYVHangup      = true;
    TTYVTDisallocate = true;
  };
}
