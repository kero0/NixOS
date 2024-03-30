{ pkgs, ... }:
{
  services = pkgs.lib.mkIf pkgs.stdenv.isLinux {
    network-manager-applet.enable = true;
    blueman-applet.enable = true;
    udiskie = {
      enable = true;
      notify = true;
    };
  };
}
