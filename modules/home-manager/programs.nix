{ pkgs, ... }:
{
  programs = {
    rclone.enable = true;
  };
  home.packages = with pkgs; [
    file
    rsync
    wget
  ];
}
