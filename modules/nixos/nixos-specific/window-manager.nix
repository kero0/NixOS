{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.my.desktop;
in
{
  options.my.desktop.enable = mkEnableOption "Enable my desktop gui";
  config = lib.mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };
      seahorse.enable = true;
      nix-ld.enable = true;
    };
    systemd.oomd.enableUserSlices = true;
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
        defaultSession = "hyprland-uwsm";
        gdm.enable = true;
      };
    };
  };
}
