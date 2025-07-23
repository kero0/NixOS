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
            package = pkgs.${pkg}.override {
              commandLineArgs =
                if pkgs.stdenv.isLinux then
                  "--enable-features=TouchpadOverscrollHistoryNavigation,VaapiVideoDecode --ignore-gpu-blocklist --enable-gpu-rasterization"
                else
                  null;
            };
            enable = true;
            extensions = [
              # ublock origin
              { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
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
          "brave"
          "chromium"
          "vivaldi"
        ]
    );
  };
}
