{ pkgs, ... }:
{
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile = {
          name = "default";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080";
              position = "0,0";
              scale = 1.2;
            }
          ];
        };
      }
    ];
  };
}
