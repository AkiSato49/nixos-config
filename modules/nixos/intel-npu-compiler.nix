{ pkgs, lib, ... }:

# The nixpkgs intel-npu-driver package is built from source and only installs:
#   - libze_intel_npu.so   (UMD driver)
#   - firmware .bin files
#   - validation test binaries
#
# It is MISSING intel-driver-compiler-npu → libnpu_driver_compiler.so,
# which is the actual compiler that converts OpenVINO IR to NPU bytecode.
# Without it, every core.compile_model(model, "NPU") call fails with
# "pfnCreate2 UNSUPPORTED_FEATURE".
#
# This module extracts libnpu_driver_compiler.so from Intel's official
# Ubuntu release tarball (v1.28.0) and adds it to hardware.graphics.extraPackages
# so it lands in /run/opengl-driver/lib alongside libze_intel_npu.so.

let
  npu-release = pkgs.fetchurl {
    url = "https://github.com/intel/linux-npu-driver/releases/download/v1.28.0/linux-npu-driver-v1.28.0.20251218-20347000698-ubuntu2404.tar.gz";
    hash = "sha256-CcyiJ9fxh5wKN4XWOSP2xjj+ogaTPWMfvnJiN8CNA8I=";
  };

  intel-npu-compiler = pkgs.stdenv.mkDerivation {
    pname = "intel-npu-compiler";
    version = "1.28.0";

    src = npu-release;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib  # libstdc++.so.6, libgcc_s.so.1
      pkgs.zlib              # libz.so.1
      pkgs.zstd              # libzstd.so.1
      pkgs.tbb       # libtbb.so.12
    ];

    # No configure/build step — just unpack and install
    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      tar -xzf $src
      # Extract the compiler .deb (ar archive with data.tar.gz inside)
      cd intel-driver-compiler-npu_*.deb.asc/.. 2>/dev/null || true
      ar x intel-driver-compiler-npu_*.deb
      tar -xzf data.tar.gz
    '';

    installPhase = ''
      mkdir -p $out/lib
      cp usr/lib/x86_64-linux-gnu/libnpu_driver_compiler.so $out/lib/
    '';

    meta = {
      description = "Intel NPU driver compiler (libnpu_driver_compiler.so)";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

in
{
  hardware.graphics.extraPackages = [ intel-npu-compiler ];

  # Convenience env vars documented for users/scripts that need them
  environment.sessionVariables = {
    ZE_ENABLE_ALT_DRIVERS = "/run/opengl-driver/lib/libze_intel_npu.so";
  };
}
