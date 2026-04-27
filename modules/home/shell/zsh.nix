{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    shellAliases = {
      # Better defaults
      ls   = "eza --icons";
      ll   = "eza -la --icons --git";
      lt   = "eza --tree --icons --level=2";
      cat  = "bat";
      find = "fd";
      grep = "rg";
      top  = "btop";
      du   = "ncdu";

      # Nix
      rebuild  = "sudo nixos-rebuild switch --flake ~/nixos-config#NixOS";
      test-rebuild = "sudo nixos-rebuild test --flake ~/nixos-config#NixOS";
      update   = "nix flake update ~/nixos-config && rebuild";
      cleanup  = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
      nix-shell = "nix-shell --run zsh";

      # Git
      g   = "git";
      gs  = "git status";
      ga  = "git add";
      gc  = "git commit";
      gp  = "git push";
      gl  = "git log --oneline --graph";
      gd  = "git diff";
      lg  = "lazygit";

      # Misc
      ".."   = "cd ..";
      "..."  = "cd ../..";
      mkdir  = "mkdir -p";
      ports  = "ss -tulpn";
      myip   = "curl ifconfig.me";
    };

    initContent = ''
      # mise (runtime manager) — others handled by HM programs integrations
      eval "$(mise activate zsh)"

      # npm global bins (e.g. pi, npx tools)
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';

    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;

      format = "$directory$git_branch$git_status$nix_shell$python$nodejs$rust$golang$cmd_duration$line_break$character";

      character = {
        success_symbol = "[λ](bold green)";
        error_symbol   = "[λ](bold red)";
      };

      directory = {
        style = "bold yellow";
        truncation_length = 4;
        truncate_to_repo = false;
      };

      git_branch = {
        style = "bold purple";
        symbol = " ";
      };

      git_status = {
        style = "bold red";
        conflicted = "⚡";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?";
        modified = "!";
        staged = "+";
        deleted = "✘";
      };

      nix_shell = {
        disabled = false;
        symbol = "❄️ ";
        style = "bold blue";
        format = "[$symbol$state]($style) ";
      };

      nodejs = {
        symbol = " ";
        style = "bold green";
      };

      python = {
        symbol = " ";
        style = "bold yellow";
      };

      rust = {
        symbol = " ";
        style = "bold red";
      };

      golang = {
        symbol = " ";
      };

      cmd_duration = {
        min_time = 2000;
        format = "took [$duration](bold yellow) ";
      };
    };
  };
}
