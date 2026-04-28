{ config, pkgs, lib, ... }:

{
  # Pi coding agent — installed via npm post-setup
  # After install, run: npm install -g @opencode-ai/pi (or equivalent)
  # Config lives at ~/pi-config/ — drop it in manually post-install

  home.packages = with pkgs; [
    nodejs_22
    mise
  ];
}
