{ lib, pkgs, ... }:

let
  source = ./control-center;
  frontend = pkgs.buildNpmPackage {
    pname = "control-centre-frontend";
    version = "0.1.0";
    src = source;
    npmDepsHash = "sha256-XIHoCOfJTrBsOslooXdeL1/It1kV5jTj+7+f3Q5KNd4=";
    npmBuildScript = "build";
    installPhase = ''
      mkdir -p $out
      cp -r dist/. $out/
    '';
  };

  python = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);
  typelibPath = lib.makeSearchPath "lib/girepository-1.0" [
    pkgs.gtk4
    pkgs.gtk4-layer-shell
    pkgs.webkitgtk_6_0
    pkgs.libsoup_3
    pkgs.graphene
    pkgs.pango.out
    pkgs.harfbuzz
    pkgs.gdk-pixbuf
    pkgs.gobject-introspection
  ];

  controlCenter = pkgs.writeShellApplication {
    name = "control-center";
    runtimeInputs = with pkgs; [
      gtk4
      gtk4-layer-shell
      webkitgtk_6_0
      wireplumber
      pavucontrol
    ];
    text = ''
      export GI_TYPELIB_PATH=${typelibPath}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}
      export LD_PRELOAD=${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so.1.3.0''${LD_PRELOAD:+:$LD_PRELOAD}
      exec ${python}/bin/python3 ${source}/bridge.py ${frontend}
    '';
  };

  toggle = pkgs.writeShellApplication {
    name = "control-center-toggle";
    runtimeInputs = [ pkgs.procps controlCenter ];
    text = ''
      # Store paths change on every rebuild. Match process responsibility, not
      # stale store path; bracket avoids matching this toggle script itself.
      if pgrep -u "$USER" -f '[c]ontrol-center/bridge.py' >/dev/null; then
        pkill -u "$USER" -f '[c]ontrol-center/bridge.py'
      else
        control-center &
      fi
    '';
  };
in {
  home.packages = [ controlCenter toggle ];
}
