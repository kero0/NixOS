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
  options.my.home.gpg.enable = mkEnableOption "Enable gpg";
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.configHome}/gnupg";
    };

    home.file."${config.programs.gpg.homedir}/gpg-agent.conf".text = lib.mkIf (pkgs.stdenv.isDarwin) ''
      default-cache-ttl ${toString (60 * 60 * 2)}
      max-cache-ttl ${toString (60 * 60 * 2)}
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      allow-emacs-pinentry
      enable-ssh-support
      ttyname $GPG_TTY
      allow-loopback-pinentry
    '';

    services.gpg-agent = {
      enable = pkgs.stdenv.isLinux;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      pinentryPackage = lib.mkIf pkgs.stdenv.isLinux pkgs.pinentry-qt;
      extraConfig = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };

    home.packages = [ pkgs.pinentry-emacs ];
  };
}
