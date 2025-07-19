{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.pass;
in
{
  options.my.home.pass.enable = mkEnableOption "Enable unix password store";
  config = mkIf cfg.enable {
    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_GENERATED_LENGTH = "14";
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
        PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
      };
    };
  };
}
