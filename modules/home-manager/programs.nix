{ pkgs, ... }:
{
  programs = {
    rclone.enable = true;
  };
  home.packages = with pkgs; [
    rsync
    wget
  ];
}
