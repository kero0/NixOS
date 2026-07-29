{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.browser;
in
{
  options.my.home.browser.enable = mkEnableOption "Enable browser config";
  config = mkIf cfg.enable {
    programs = attrsets.mergeAttrsList (
      map
        (pkg: {
          ${pkg} = {
            package = pkgs.${pkg};
            commandLineArgs = lib.mkIf pkgs.stdenv.isLinux [
              "--enable-features=TouchpadOverscrollHistoryNavigation,VaapiVideoDecode"
              "--ignore-gpu-blocklist"
              "--enable-gpu-rasterization"
              "--ozone-platform-hint=auto"
              "--enable-features=UseOzonePlatform"
            ];
            enable = true;
            extensions = [
              # ublock origin lite
              { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; }
              # bitwarden
              { id = "nngceckbapebfimnlniiiahkandclblb"; }
              # video speed controller
              { id = "nffaoalbilbmmfgbnbgppjihopabppdk"; }
              # sponsorblock
              { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; }
            ];
          };
        })
        [
          "chromium"
          "vivaldi"
        ]
    );
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "chromium.desktop";
        "x-scheme-handler/http" = "chromium.desktop";
        "x-scheme-handler/https" = "chromium.desktop";
        "x-scheme-handler/about" = "chromium.desktop";
        "x-scheme-handler/unknown" = "chromium.desktop";
      };
    };
  };
}
