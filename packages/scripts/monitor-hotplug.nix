{ pkgs, myuser, config, ... }:
let
  hotplug-monitor-script = with pkgs; writeScriptBin "hotplug-monitor.sh" ''
    ${xorg.xrandr}/bin/xrandr | \
    ${gawk}/bin/awk 'NR!=1 && /^\w/ { print $1 }' | \
    ${bash}/bin/bash -c 'read main && while read line ; do ${xorg.xrandr}/bin/xrandr --output $line --auto --right-of $main; done'
  '';
  xauth = if config.services.xserver.displayManager.gdm.enable then "/run/user/1000/gdm/Xauthority" else "/home/${myuser}/.Xauthority";
in
{
  services.udev.extraRules = ''
    KERNEL=="card0", ACTION=="change", SUBSYSTEM=="drm", ENV{XAUTHORITY}=${xauth}, ENV{DISPLAY}=":0", RUN+="${pkgs.bash}/bin/bash ${hotplug-monitor-script}/bin/hotplug-monitor.sh"       
  '';
}
