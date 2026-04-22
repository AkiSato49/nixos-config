{ config, pkgs, ... }:

{
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 32;
      gtk_dark = true;
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window {
        margin: 0;
        border: 2px solid #d79921;
        background-color: #1d2021;
        border-radius: 10px;
      }

      #input {
        margin: 8px;
        padding: 8px 16px;
        background-color: #282828;
        color: #ebdbb2;
        border-radius: 8px;
        border: 1px solid #3c3836;
        outline: none;
      }

      #input:focus {
        border-color: #d79921;
      }

      #inner-box {
        margin: 4px;
        background-color: transparent;
      }

      #outer-box {
        margin: 0;
        padding: 4px;
        background-color: transparent;
      }

      #scroll {
        margin: 0 4px 4px 4px;
      }

      #text {
        color: #ebdbb2;
        padding: 4px 8px;
      }

      #entry {
        border-radius: 6px;
        padding: 4px;
      }

      #entry:selected {
        background-color: #3c3836;
      }

      #text:selected {
        color: #d79921;
      }

      #img {
        margin-right: 8px;
      }
    '';
  };
}
