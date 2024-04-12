{ pkgs, ... }:
{
  systemd.user.services.swaync = {
    Unit = {
      Description = "Notification center";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      Restart = "always";
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}
