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
  options.my.home.browser = {
    enable = mkEnableOption "Enable browser config";
    commandLineArgs = mkOption {
      type = types.listOf types.str;
      default =
        if pkgs.stdenv.isLinux then
          [
            "--enable-features=TouchpadOverscrollHistoryNavigation,VaapiVideoDecode"
            "--ignore-gpu-blocklist"
            "--enable-gpu-rasterization"
            "--ozone-platform-hint=auto"
            "--enable-features=UseOzonePlatform"
          ]
        else
          [ ];
      description = "List of common command line arguments for all browsers";
    };
  };
  config = mkIf cfg.enable {
    programs = attrsets.mergeAttrsList (
      map
        (pkg: {
          ${pkg} = {
            enable = true;
            inherit (cfg) commandLineArgs;
            package = mkIf pkgs.stdenv.isDarwin null;
            extensions = [
              # ublock origin lite
              { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; }
              # bitwarden
              { id = "nngceckbapebfimnlniiiahkandclblb"; }
              # video speed controller
              { id = "nffaoalbilbmmfgbnbgppjihopabppdk"; }
              # sponsorblock
              { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; }
            ]
            # nordvpn
            ++ lists.optional (pkg == "vivaldi") { id = "fjoaledfpmneenckfbpdfhkmimnjocfa"; };
          };
        })
        [
          "chromium"
          "vivaldi"
        ]
    );
    xdg.mimeApps = {
      enable = mkDefault pkgs.stdenv.isLinux;
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
