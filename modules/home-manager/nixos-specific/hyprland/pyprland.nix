{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland.pyprland;
in
{
  options.my.home.hyprland.pyprland.enable = mkEnableOption "Enable pyprland utility";
  config = mkIf cfg.enable {
    home.packages = [ pkgs.pyprland ];
    systemd.user.services.pyprland = {
      Unit = {
        Description = "Helper tool for Hyprland";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.pyprland}/bin/pypr";
        ExecStop = "${pkgs.bash}/bin/bash -c 'rm /tmp/hypr/*/.pyprland.sock'";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
    xdg.configFile."hypr/pyprland.toml".source = (pkgs.formats.toml { }).generate "pyprland.toml" {
      pyprland.plugins = [ "scratchpads" ];
      scratchpads = {
        bluetooth = {
          animation = "fromRight";
          command = "blueman-manager";
          class = ".blueman-manager-wrapped";
          size = "40% 70%";
          unfocus = "hide";
          lazy = true;
        };
        term = {
          animation = "fromTop";
          command = "kitty --class kitty-dropterm";
          class = "kitty-dropterm";
          size = "100% 100%";
          max_size = "100% 100%";
          margin = 0;
          multi = false;
          preserve_aspect = true;
        };
        volume = {
          animation = "fromRight";
          command = "pavucontrol";
          class = "pavucontrol";
          size = "40% 70%";
          unfocus = "hide";
          lazy = true;
        };
      };
    };
  };
}
