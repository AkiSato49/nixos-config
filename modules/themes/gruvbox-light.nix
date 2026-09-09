# Gruvbox Light — hard contrast, warm paper background
# Research basis: positive polarity (dark-on-light) proven faster + more accurate
# bg_hard: warm off-white (not pure white — reduces halation)
# fg: near-black warm tone (~15:1 contrast vs bg_hard)
# All accent colours from Gruvbox Light palette
{
  name = "gruvbox-light";

  colors = {
    bg_hard   = "#f9f5d7";   # gruvbox light hard bg — warm off-white
    bg        = "#fbf1c7";   # gruvbox light bg
    bg1       = "#ebdbb2";   # gruvbox light bg1
    bg2       = "#d5c4a1";   # gruvbox light bg2
    fg        = "#3c3836";   # gruvbox light fg — warm near-black
    fg_dim    = "#665c54";   # gruvbox light fg4
    fg_muted  = "#928374";   # gruvbox light gray
    yellow    = "#b57614";   # gruvbox light yellow — darker for contrast on light bg
    yellow_br = "#d79921";
    orange    = "#af3a03";
    red       = "#9d0006";   # gruvbox light red
    red_br    = "#cc241d";
    green     = "#79740e";   # gruvbox light green
    green_br  = "#98971a";
    teal      = "#427b58";   # gruvbox light teal
    teal_br   = "#689d6a";
    blue      = "#076678";   # gruvbox light blue
    blue_br   = "#458588";
    purple    = "#8f3f71";   # gruvbox light purple
    purple_br = "#b16286";
    gray      = "#928374";
  };

  borders = {
    active   = "rgba(b57614ff)";   # solid yellow-ochre
    inactive = "rgba(d5c4a1ff)";
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
    size_ui   = 12;
    size_mono = 13.5;
  };

  gtk = {
    theme       = "Gruvbox-Light";
    icons       = "Papirus-Light";
    cursor      = "Bibata-Modern-Classic";
    cursor_size = 24;
    font_name   = "JetBrainsMono Nerd Font";
    font_size   = 11;
  };

  greetd = {
    greeting  = "welcome";
    time_fmt  = "%H:%M";
    theme_str = "border=yellow;text=black;prompt=green;time=blue;action=yellow;button=red;container=white;input=black";
  };

  variants = {
    wlogout_text     = true;
    hyprlock_minimal = true;
    waybar_flat      = true;
  };
}
