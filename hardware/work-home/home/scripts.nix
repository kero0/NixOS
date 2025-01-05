{ config, pkgs, ... }:
with pkgs;
let
  aosp-make-compile-commands = writeScriptBin "aosp-make-compile-commands" ''
    #!/usr/bin/env bash
    if [ -z "$1" ]; then
      echo "No target provided"
      exit 1
    fi
    if [ ! -f build/envsetup.sh ]; then
      echo "Not in AOSP workspace root"
      exit 1
    fi
    source build/envsetup.sh
    lunch $1
    export SOONG_GEN_COMPDB=1
    export SOONG_GEN_COMPDB_DEBUG=1
    export SOONG_LINK_COMPDB_TO=$ANDROID_HOST_OUT
    make nothing
    ln -s out/soong/development/ide/compdb/compile_commands.json compile_commands.json
  '';
in
{
  home.packages = [ aosp-make-compile-commands ];
}
