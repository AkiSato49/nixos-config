{ config, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.symbols-only
      atkinson-hyperlegible-next
      atkinson-hyperlegible-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Atkinson Hyperlegible Mono" "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
        sansSerif = [ "Atkinson Hyperlegible Next" "Noto Sans" ];
        serif     = [ "Noto Serif" ];
        emoji     = [ "Noto Color Emoji" ];
      };
    };
  };
}
