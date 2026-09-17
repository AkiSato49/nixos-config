{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    shellAliases = {
      # Navigation
      cd = "z";

      # Better defaults
      ls   = "eza --icons";
      ll   = "eza -la --icons --git";
      lt   = "eza --tree --icons --level=2";
      cat  = "bat";
      find = "fd";
      grep = "rg";
      top  = "btm";
      du   = "ncdu";

      # Nix
      rebuild  = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
      test-rebuild = "sudo nixos-rebuild test --flake /etc/nixos#$(hostname)";
      update   = "nix flake update --flake /etc/nixos && rebuild";
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

      # Secrets from sops-nix (/run/secrets/*, owned by lawliet). See
      # /etc/nixos/modules/nixos/secrets.nix. Guarded so non-casino/no-sops
      # shells still start clean.
      _load_secret() { [ -r "$1" ] && export "$2=$(cat "$1")"; }
      _load_secret /run/secrets/meta_model_api_key    MODEL_API_KEY
      _load_secret /run/secrets/gog_keyring_password  GOG_KEYRING_PASSWORD
      _load_secret /run/secrets/openai_api_key        OPENAI_API_KEY
      _load_secret /run/secrets/figma_token           FIGMA_TOKEN
      unset -f _load_secret

      # syncforce [folder|all]: force syncthing rescan on mambo + casino.
      # Defaults to School folder. Pull follows scan automatically (~10s).
      syncforce() {
        local folder="''${1:-School}"
        local query=""
        [[ "$folder" == "all" ]] || query="?folder=''${folder}"
        local mkey
        mkey=$(grep -oP '<apikey>\K[^<]+' ~/.config/syncthing/config.xml)
        curl -s -X POST -H "X-API-Key: $mkey" "http://127.0.0.1:8384/rest/db/scan''${query}" >/dev/null && echo "mambo ''${folder}: scan triggered"
        ssh lawliet@100.105.22.71 "CKEY=\$(grep -oP '<apikey>\K[^<]+' ~/.config/syncthing/config.xml); curl -s -X POST -H \"X-API-Key: \$CKEY\" \"http://127.0.0.1:8384/rest/db/scan''${query}\" >/dev/null && echo \"casino ''${folder}: scan triggered\""
      }

      # add-secret <sops_key> [ENV_VAR]: store value via sops, declare in
      # secrets.nix, wire _load_secret above. Value prompted hidden, never
      # passed as argv, never saved to history. Run `rebuild` after.
      add-secret() {
        local key="$1" envvar="$2"
        [[ "$key" =~ ^[a-z0-9_]+$ ]] || { echo "usage: add-secret <sops_key> [ENV_VAR] (e.g. add-secret figma_token)" >&2; return 1; }
        : "''${envvar:=${key:u}}"
        [[ "$envvar" =~ ^[A-Z_][A-Z0-9_]*$ ]] || { echo "bad ENV_VAR: $envvar" >&2; return 1; }
        local val=""
        read -sr "val?secret value for $key: "; echo
        [[ -n "$val" ]] || { echo "empty, abort" >&2; return 1; }
        local json; json=$(print -r -- "$val" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))') || return 1
        val=""
        sops set /etc/nixos/secrets/secrets.yaml "[\"$key\"]" "$json" || return 1
        grep -q "\b$key\.owner" /etc/nixos/modules/nixos/secrets.nix || {
          sed -i "/secrets = {/a\      $key.owner = user;" /etc/nixos/modules/nixos/secrets.nix || return 1
          echo "declared $key in secrets.nix"
        }
        grep -q "/run/secrets/$key" /etc/nixos/modules/home/shell/zsh.nix || {
          sed -i "s|_load_secret /run/secrets/openai_api_key.*|&\n      _load_secret /run/secrets/$key  $envvar|" /etc/nixos/modules/home/shell/zsh.nix || return 1
          echo "wired $envvar in zsh.nix"
        }
        echo "stored $key -> $envvar. Next: rebuild, then printenv $envvar | wc -c"
      }
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

      format = "$hostname$directory$git_branch$git_status$nix_shell$python$nodejs$rust$golang$cmd_duration$line_break$character";

      hostname = {
        ssh_only = false;
        style = "bold cyan";
        format = "[$hostname](bold cyan) ";
      };

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
