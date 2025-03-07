{ pkgs, ... }:
let
  aosp-make-compile-commands = pkgs.writeScriptBin "aosp-make-compile-commands" ''
    #!/usr/bin/env bash
    if [ -z "$1" ]; then
      echo "No target provided"
      exit 1
    fi

    root="$(repo --show-toplevel)"
    pushd $root

    source build/envsetup.sh
    lunch $1
    export SOONG_GEN_COMPDB=1
    export SOONG_GEN_COMPDB_DEBUG=1
    export SOONG_LINK_COMPDB_TO=$ANDROID_HOST_OUT
    make nothing
    popd
    ln -s $root/out/soong/development/ide/compdb/compile_commands.json compile_commands.json
  '';
  android-env = pkgs.buildFHSEnv {
    name = "android-env";
    targetPkgs =
      pkgs: with pkgs; [
        android-tools
        bc
        bison
        ccache
        curl
        flex
        fontconfig
        freetype
        gcc
        git
        gitRepo
        gnumake
        gnupg
        gperf
        imagemagick
        jre8_headless
        libxcrypt-legacy
        libxml2
        lsof
        lzip
        lzop
        m4
        ncurses5
        nettools
        openjdk17
        openssl
        openssl.dev
        openssl_1_1
        perl
        procps
        psmisc
        python2
        (python3.withPackages (p: with p; [ demjson3 ]))
        rsync
        schedtool
        unzip
        util-linux
        which
        zip
      ];
    multiPkgs =
      pkgs: with pkgs; [
        ncurses5.dev
        libcxx.dev
        readline.dev
        zlib
      ];
    runScript = "bash";
    multiArch = true;
    profile = ''
      export ALLOW_NINJA_ENV=true
      export LD_LIBRARY_PATH=/usr/lib:/usr/lib32''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
      if [ -d /mnt/ccache/ ]; then
         export CCACHE_EXEC=${pkgs.ccache}/bin/ccache
         export CCACHE_DIR=/mnt/ccache
         export USE_CCACHE=1
      else
         echo "ccache is not properly setup"
      fi
    '';
  };
in
{
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
    "python-2.7.18.8"
  ];
  home.packages = [
    aosp-make-compile-commands
    android-env
  ];
}
