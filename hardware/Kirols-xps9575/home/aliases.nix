{ pkgs, ... }:
let
  dbox-com = name: "${pkgs.distrobox}/bin/distrobox enter ${name}";
in
{
  home.shellAliases = {
    # distrobox
    # archlinux = "${distrobox}/bin/distrobox enter arch";
    # ros = "${distrobox}/bin/distrobox enter ros-noetic";
    # matlab = "${distrobox}/bin/distrobox enter matlab";
    box-archlinux = dbox-com "arch";
    box-matlab = dbox-com "matlab";
    box-ros = dbox-com "ros-noetic";
  };
}
