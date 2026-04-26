{
  name = "gruvbox-dark";

  colors = {
    bg_hard   = "#1d2021";
    bg        = "#282828";
    bg1       = "#3c3836";
    bg2       = "#504945";
    fg        = "#ebdbb2";
    fg_dim    = "#a89984";
    fg_muted  = "#665c54";
    yellow    = "#d79921";
    yellow_br = "#fabd2f";
    orange    = "#d65d0e";
    red       = "#cc241d";
    red_br    = "#fb4934";
    green     = "#98971a";
    green_br  = "#b8bb26";
    teal      = "#689d6a";
    teal_br   = "#8ec07c";
    blue      = "#458588";
    blue_br   = "#83a598";
    purple    = "#b16286";
    purple_br = "#d3869b";
    gray      = "#928374";
  };

  borders = {
    active   = "rgba(d79921ff) rgba(b57614ff) 45deg";
    inactive = "rgba(282828ff)";
  };

  geometry = {
    rounding    = 8;
    blur        = true;
    blur_size   = 3;
    blur_passes = 2;
    shadows     = true;
    gaps_in     = 5;
    gaps_out    = 10;
    border_size = 2;
  };

  font = {
    ui        = "JetBrainsMono Nerd Font";
    mono      = "JetBrainsMono Nerd Font";
    size_ui   = 13;
    size_mono = 13.5;
  };

  gtk = {
    theme       = "Gruvbox-Dark-BL";
    icons       = "Papirus-Dark";
    cursor      = "Bibata-Modern-Classic";
    cursor_size = 24;
    font_name   = "Noto Sans";
    font_size   = 11;
  };

  greetd = {
    greeting  = "welcome back";
    time_fmt  = "%H:%M";
    theme_str = "border=yellow;text=white;prompt=yellow;time=yellow;action=yellow;button=red;container=black;input=white";
  };

  variants = {
    wlogout_text     = false;
    hyprlock_minimal = false;
    waybar_flat      = false;
  };
}
