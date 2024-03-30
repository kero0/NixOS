{ pkgs, ... }:
{
  services.xserver.windowManager.qtile.enable = true;
  environment.systemPackages = with pkgs; [
    pamixer
    playerctl
    scrot
  ];

}
