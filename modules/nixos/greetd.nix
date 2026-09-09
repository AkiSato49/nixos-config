{ inputs, pkgs, theme, ... }:

let
  wallpaper = ../../assets/wallpapers/casino-login.png;
  hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in {
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  # Noctalia Greeter is native greetd login UI. It starts its own compositor;
  # do not wrap it in Cage or run a second greeter alongside it.
  programs.noctalia-greeter = {
    enable = true;
    # Upstream greeter starts PAM only after Enter. Patch starts fprintd when
    # greeter appears and waits for PAM's actual password prompt on fallback.
    package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../../patches/noctalia-greeter-device-first-auth.patch ];
    });
    greeter-args = "--session Hyprland";
    settings = {
      appearance = {
        # Complete palette makes greeter use system Gruvbox theme instead of
        # Noctalia Greeter's built-in default scheme.
        scheme = "Synced";
        theme_mode = "light";
        font_family = theme.font.ui;
        palette = {
          primary = theme.colors.yellow;
          on_primary = theme.colors.bg_hard;
          secondary = theme.colors.blue;
          on_secondary = theme.colors.bg_hard;
          tertiary = theme.colors.purple;
          on_tertiary = theme.colors.bg_hard;
          error = theme.colors.red;
          on_error = theme.colors.bg_hard;
          surface = theme.colors.bg;
          on_surface = theme.colors.fg;
          surface_variant = theme.colors.bg1;
          on_surface_variant = theme.colors.fg_dim;
          outline = theme.colors.bg2;
          shadow = theme.colors.bg_hard;
          hover = theme.colors.yellow_br;
          on_hover = theme.colors.bg_hard;
        };
        wallpaper = {
          path = "${wallpaper}";
          fill_mode = "crop";
        };
      };
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
        path = "${pkgs.bibata-cursors}/share/icons";
      };
      # Skip user picker; this is only local desktop account.
      user.default = "lawliet";
      keyboard.layout = "us";
      # Submit an empty field to begin PAM fingerprint auth; no fake password.
      auth.allow_empty_password = true;
      idle.timeout = 300;
    };
  };

  # Register Hyprland system-wide. This installs its Wayland desktop entry in
  # /run/current-system/sw/share/wayland-sessions, where Noctalia Greeter
  # discovers it. Without this, greeter falls back to its "Shell" session.
  programs.hyprland = {
    enable = true;
    package = hyprland;
  };

  # `session.default` wins over mutable greeter preferences and prevents a
  # previously saved Shell selection from launching /bin/sh after login.
  programs.noctalia-greeter.settings.session.default = "Hyprland";

  # Explicit session user keeps Noctalia Greeter's generated greetd command.
  services.greetd.settings.default_session.user = "greeter";

  # Minimal recovery: Ctrl+Alt+F2 -> PAM text login.
  # Keep this independent from greetd and Noctalia Greeter.
  systemd.services."getty@tty2".wantedBy = [ "getty.target" ];
}
