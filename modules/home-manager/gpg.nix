{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.gpg;
in
{
  options.my.home.gpg = {
    enable = mkEnableOption "Enable gpg";
    pinentry = mkPackageOption pkgs "pinentry" {
      default = if pkgs.stdenv.isLinux then "pinentry-qt" else "pinentry_mac";
    };
  };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.configHome}/gnupg";
    };

    services.gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      enableExtraSocket = true;
      defaultCacheTtl = 60 * 60 * 2;
      maxCacheTtl = 60 * 60 * 2;

      pinentry.package = cfg.pinentry;

      extraConfig = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };

    home.packages = [ pkgs.pinentry-emacs ];
  };
}
