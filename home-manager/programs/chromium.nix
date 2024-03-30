{ pkgs, ... }: {
  programs.chromium = pkgs.lib.mkIf pkgs.stdenv.isLinux {
    package = pkgs.chromium.override {
      commandLineArgs = "--enable-features=VaapiVideoDecode --ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy";
    };
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
      { id = "nngceckbapebfimnlniiiahkandclblb"; }
    ];
  };
}
