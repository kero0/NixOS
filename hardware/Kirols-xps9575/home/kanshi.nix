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
              mode = "3840x2160";
              position = "0,0";
              scale = 2.0;
            }
          ];
        };
      }
      {
        profile = {
          name = "docked";
          outputs = [
            {
              criteria = "*";
              mode = "2560x1440";
              position = "0,20";
            }
            {
              criteria = "*";
              mode = "1920x1200";
              position = "2560,20";
            }
            {
              criteria = "eDP-1";
              mode = "3840x2160";
              position = "4480,0";
              scale = 2.0;
            }
          ];
        };
      }
    ];
  };
}
