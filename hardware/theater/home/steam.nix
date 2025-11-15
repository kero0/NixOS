{ osConfig, ... }:
{
  systemd.user.services.steam = {
    Unit = {
      Description = "Open Steam in the background at boot";
    };
    Service = {
      ExecStart = "${osConfig.programs.steam.package} -nochatui -nofriendsui %U";
      WantedBy = [ "graphical-session.target" ];
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
