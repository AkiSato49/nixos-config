# Gruvbox Swiss — Prayer Flag
# Five elements: blue (sky/wind), white (air), red (fire), green (water), yellow (earth)
# Mapped to gruvbox palette, applied as semantic accents across the UI.
# Swiss grid: no rounding, no blur, tight gaps, thin borders, monospace throughout.
{
  name = "gruvbox-prayer";

  colors = {
    bg_hard   = "#1d2021";
    bg        = "#282828";
    bg1       = "#3c3836";
    bg2       = "#504945";
    fg        = "#ebdbb2";
    fg_dim    = "#a89984";
    fg_muted  = "#665c54";
    yellow    = "#d79921";   # earth  — primary accent
    yellow_br = "#fabd2f";
    orange    = "#d65d0e";
    red       = "#cc241d";   # fire   — critical / poweroff
    red_br    = "#fb4934";
    green     = "#98971a";
    green_br  = "#b8bb26";
    teal      = "#689d6a";   # water  — connected / charging / reboot
    teal_br   = "#8ec07c";
    blue      = "#458588";   # sky    — bluetooth / hibernate / suspend
    blue_br   = "#83a598";
    purple    = "#b16286";
    purple_br = "#d3869b";
    gray      = "#928374";
  };

  borders = {
    active   = "rgba(d79921ff)";  # solid yellow, no gradient
    inactive = "rgba(3c3836ff)";
  };

  geometry = {
    rounding    = 0;
    blur        = false;
    blur_size   = 0;
    blur_passes = 0;
    shadows     = false;
    gaps_in     = 4;
    gaps_out    = 8;
    border_size = 1;
  };

  font = {
    ui        = "JetBrainsMono Nerd Font";
    mono      = "JetBrainsMono Nerd Font";
    size_ui   = 16;
    size_mono = 17.0;
  };

  gtk = {
    theme       = "Gruvbox-Dark-B";
    icons       = "Papirus-Dark";
    cursor      = "Bibata-Modern-Classic";
    cursor_size = 24;
    font_name   = "JetBrainsMono Nerd Font";
    font_size   = 11;
  };

  greetd = {
    greeting  = "welcome";
    time_fmt  = "%H:%M";
    theme_str = "border=yellow;text=white;prompt=green;time=blue;action=yellow;button=red;container=black;input=white";
  };

  variants = {
    wlogout_text     = true;
    hyprlock_minimal = true;
    waybar_flat      = true;
  };
}
