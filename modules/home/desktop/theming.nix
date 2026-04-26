{ config, pkgs, theme, ... }:

{
  gtk = {
    enable = true;
    theme = {
      name    = theme.gtk.theme;
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name    = theme.gtk.icons;
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name    = theme.gtk.cursor;
      package = pkgs.bibata-cursors;
      size    = theme.gtk.cursor_size;
    };
    font = {
      name = theme.gtk.font_name;
      size = theme.gtk.font_size;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  home.sessionVariables = {
    GTK_THEME            = theme.gtk.theme;
    XCURSOR_THEME        = theme.gtk.cursor;
    XCURSOR_SIZE         = toString theme.gtk.cursor_size;
    QT_QPA_PLATFORMTHEME = "gtk2";
  };

  home.pointerCursor = {
    name    = theme.gtk.cursor;
    package = pkgs.bibata-cursors;
    size    = theme.gtk.cursor_size;
    gtk.enable = true;
    x11.enable = false;
  };
}
