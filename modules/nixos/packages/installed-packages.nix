{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.allpkgs;
in
with lib;
{
  options.my.allpkgs.enable = mkEnableOption "Install my desktop apps";
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        # Dev stuff
        git
        python3

        # personal stuff
        ## tools
        rsync
        wget
        ## other
        bottom
      ]
      ++ lib.lists.optionals (stdenv.isLinux) [
        # browsers
        (google-chrome.override {
          commandLineArgs = "--enable-features=TouchpadOverscrollHistoryNavigation,VaapiVideoDecode --ignore-gpu-blocklist --enable-gpu-rasterization";
        })

        # bitwarden
        bitwarden
        bitwarden-cli

        # document writing
        xournalpp

        # other
        alacritty
        mpv
        qalculate-gtk
        scrot
        zathura
      ];
  };
}
