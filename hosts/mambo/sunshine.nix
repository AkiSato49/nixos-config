{ pkgs, ... }:

{
  # Low-latency desktop streaming host; pair from Moonlight on casino.
  services.sunshine = {
    enable = true;
    openFirewall = true;
  };

  # Resolve needs Mambo's RTX 3070 Ti; casino's Intel iGPU is unsupported.
  home-manager.users.lawliet.home.packages = [ pkgs.davinci-resolve ];
}
