{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktop;
in
with lib;
{
  options.my.desktop.enable = mkEnableOption "Enable my desktop gui";
  config = lib.mkIf cfg.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    programs = {
      hyprland.enable = true;
      seahorse.enable = true;
    };
    security.pam.services = {
      hyprlock = { };
      ${config.my.user.username}.enableGnomeKeyring = true;
    };
    services = {
      devmon.enable = true;
      gnome.gnome-keyring.enable = true;
      udisks2.enable = true;
      displayManager = {
        autoLogin = {
          enable = false;
          user = config.my.user.username;
        };
        defaultSession = "hyprland";
      };
      xserver = {
        enable = true;
        desktopManager.xterm.enable = false;
        xkb.layout = "us";
        displayManager = {
          gdm = {
            enable = true;
            wayland = true;
          };
        };
      };
    };
  };
}
