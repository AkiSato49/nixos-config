{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Better CLI tools
    fzf
    ripgrep
    bat
    eza
    fd
    zoxide
    jq
    httpie
    curlie

    # Git
    gh
    lazygit
    delta

    # Dev essentials
    direnv
    mise
    gnumake
    gcc
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374"
      "--color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934"
      "--color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934"
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      italic-text = "always";
      pager = "less -FR";
    };
  };

  programs.git = {
    enable = true;
    userName  = "AkiSato49";
    userEmail = "carlosakisato@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;
      core.editor = "nvim";
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        syntax-theme = "gruvbox-dark";
        side-by-side = true;
        line-numbers = true;
      };
    };
    aliases = {
      st   = "status";
      co   = "checkout";
      br   = "branch";
      lg   = "log --oneline --graph --decorate";
      undo = "reset --soft HEAD~1";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor    = [ "yellow" "bold" ];
          inactiveBorderColor  = [ "white" ];
          selectedLineBgColor  = [ "#3c3836" ];
        };
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
