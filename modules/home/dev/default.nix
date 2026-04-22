{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node / JS ecosystem
    nodejs
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

    # API testing
    bruno                       # open-source Postman alternative

    # DB GUI
    dbeaver-bin

    # Build tools
    pkg-config
  ];

  # mise — runtime version manager (~nvm + pyenv + rbenv in one)
  home.file.".config/mise/config.toml".text = ''
    [settings]
    experimental = true

    [tools]
    node = "lts"
    python = "3.12"
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
