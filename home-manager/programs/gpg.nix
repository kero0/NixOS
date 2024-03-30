{ config, pkgs, lib, ... }: {
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.configHome}/gnupg";
  };

  home.file."${config.programs.gpg.homedir}/gpg-agent.conf".text =
    lib.mkIf (pkgs.stdenv.isDarwin) ''
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

    pinentryFlavor = "emacs";
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };

  home.packages = [ pkgs.pinentry-emacs ];
}
