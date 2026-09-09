{ config, pkgs, ... }:

let
  # Wrangler propagates its bundled TypeScript into profiles, conflicting with
  # standalone TypeScript. Expose only Wrangler's executable.
  wranglerCli = pkgs.writeShellScriptBin "wrangler" ''
    exec ${pkgs.wrangler}/bin/wrangler "$@"
  '';
in {
  home.packages = with pkgs; [
    # Node / JS ecosystem
    nodejs_22
    bun
    pnpm
    typescript

    # Python
    python3
    uv                          # fast pip/venv replacement

    # Rust
    rustup                      # manages rustc + cargo

    # Go
    go

    # Docker
    docker-compose

    # API and browser testing
    bruno                       # open-source Postman alternative
    playwright-test             # version-matched CLI; browsers come from nixpkgs

    # Cloud providers
    awscli2
    wranglerCli                 # Cloudflare Workers, Pages, and R2

    # S3-compatible storage (AWS S3, Cloudflare R2, MinIO)
    rclone
    s5cmd

    # Infrastructure and Kubernetes
    opentofu
    kubectl
    kubernetes-helm

    # Secret encryption
    sops
    age

    # DB GUI
    dbeaver-bin

    # Build tools
    pkg-config
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/.local/share/go";
    GOBIN  = "$HOME/.local/bin";

    # Use NixOS-patched browsers. Project @playwright/test must match nixpkgs.
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/go/bin"
  ];

  # mise — runtime version manager (~nvm + pyenv + rbenv in one)
  home.file.".config/mise/config.toml".text = ''
    [settings]
    experimental = true

    [tools]
    node = "lts"
    python = "3.12"
    "npm:vercel" = "58.7.1"
  '';

  # Default devShell template (copy to any project)
  home.file.".config/devshell-template.nix".text = ''
    # Copy to project root as shell.nix
    { pkgs ? import <nixpkgs> {} }:
    pkgs.mkShell {
      buildInputs = with pkgs; [
        nodejs
        bun
        pnpm
      ];
      shellHook = '''
        echo "Dev shell ready"
      ''';
    }
  '';
}
