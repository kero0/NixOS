{ pkgs, ... }:
{
  programs = {
    rclone.enable = true;
    zathura.enable = true;
  };
  home.packages = with pkgs; [
    python3
    qalculate-gtk
    rsync
    wget
  ];
}
