{ config, pkgs, ... }:
{
  programs.git = {
    lfs.enable = true;
    extraConfig = {
      github.user = "kbakheat_ford";
      user.signingKey = "C6F92AA1FA6C97720DD344CA0F9995D80D7ADAFE";
      credentials.helper = "store";
      http.cookiefile = "${config.xdg.configHome}/git/cookies";
      http.cookieFile = "${config.xdg.configHome}/git/cookies";
      push.autoSetupRemote = true;
      core.autocrlf = true;
    };
  };

  wayland.windowManager.hyprland.package = config.nixGL pkgs.hyprland;
}
