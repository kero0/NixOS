{ pkgs, ... }:
{
  programs = {
    rclone.enable = true;
  };
  home.packages = with pkgs; [
    file
    lsof
    pciutils
    rsync
    usbutils
    wget
  ];
}
