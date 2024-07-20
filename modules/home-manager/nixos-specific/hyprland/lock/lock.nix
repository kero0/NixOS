{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland.lock;
in
{
  options.my.home.hyprland.lock.enable = mkEnableOption "Enable screen lock";
  config = mkIf cfg.enable {
    systemd.user.services.hypridle = {
      Unit = {
        Description = "Hyprland's idle daemon";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
    home.packages = with pkgs; [ hyprlock ];
    xdg.configFile = {
      "hypr/hypridle.conf".source = ./hypridle.conf;
      "hypr/hyprlock.conf".source = ./hyprlock.conf;
    };
  };
}
