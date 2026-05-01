{ config, pkgs, theme, ... }:
let
  c    = theme.colors;
  flat = theme.variants.waybar_flat;

  # Prayer: yellow accent, blue highlights, teal info — prayer flag semantics
  # Dark:   red-heavy — original gruvbox fzf feel
  fzfColors = if flat then [
    "--color=bg+:${c.bg1},bg:${c.bg_hard},spinner:${c.yellow},hl:${c.blue_br}"
    "--color=fg:${c.fg},header:${c.fg_dim},info:${c.teal_br},pointer:${c.yellow}"
    "--color=marker:${c.teal},fg+:${c.fg},prompt:${c.yellow},hl+:${c.yellow_br}"
  ] else [
    "--color=bg+:${c.bg1},bg:${c.bg},spinner:${c.red_br},hl:${c.gray}"
    "--color=fg:${c.fg},header:${c.gray},info:${c.teal_br},pointer:${c.red_br}"
    "--color=marker:${c.red_br},fg+:${c.fg},prompt:${c.red_br},hl+:${c.red_br}"
  ];
in {
  home.packages = with pkgs; [
    fzf
    ripgrep
    bat
    eza
    fd
    zoxide
    jq
    httpie
    curlie
    gh
    lazygit
    delta
    direnv
    mise
    gnumake
    gcc

    # New
    carapace   # shell completions for 500+ commands
    procs      # modern ps
    duf        # pretty df
    dust       # visual du
    bottom     # better htop (btm)
    tldr       # short man pages
    zellij     # modern terminal multiplexer
  ];

  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
    defaultOptions       = [ "--height 40%" "--layout=reverse" "--border" ] ++ fzfColors;
  };

  programs.bat = {
    enable = true;
    config = {
      theme       = "gruvbox-dark";
      italic-text = "always";
      pager       = "less -FR";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name  = "AkiSato49";
      user.email = "carlosakisato@gmail.com";
      init.defaultBranch  = "main";
      push.autoSetupRemote = true;
      pull.rebase         = false;
      core.editor         = "nvim";
      alias = {
        st   = "status";
        co   = "checkout";
        br   = "branch";
        lg   = "log --oneline --graph --decorate";
        undo = "reset --soft HEAD~1";
      };
    };
  };

  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate      = true;
      light         = false;
      syntax-theme  = "gruvbox-dark";
      side-by-side  = true;
      line-numbers  = true;
    };
  };

  programs.direnv = {
    enable               = true;
    enableZshIntegration = true;
    nix-direnv.enable    = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor   = [ "yellow" "bold" ];
        inactiveBorderColor = [ "white" ];
        selectedLineBgColor = [ "${c.bg1}" ];
      };
    };
  };

  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
  };

  programs.carapace = {
    enable               = true;
    enableZshIntegration = true;
  };

  programs.zellij = {
    enable               = true;
    enableZshIntegration = true;
  };
}
