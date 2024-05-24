{ pkgs, ... }:
{
  services.kanshi = {
    enable = false;
    systemdTarget = "graphical-session.target";
    # settings = { };
  };
}
