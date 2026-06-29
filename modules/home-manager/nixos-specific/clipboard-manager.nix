{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.clipboard-manager;
in
{
  options.my.home.clipboard-manager.enable = mkEnableOption "Enable clipboard-manager";
  config = mkIf cfg.enable {
    services.cliphist.enable = true;
    systemd.user.services = {
      wl-clip-persist = {
        Unit = {
          Description = "Persist clipboard when application exits";
          PartOf = [ "wayland-session.target" ];
          After = [ "wayland-session.target" ];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
          Restart = "always";
        };

        Install = {
          WantedBy = [ "wayland-session.target" ];
        };
      };
    };

    wayland.windowManager.hyprland.settings.bind = [
      {
        _args = [
          (lib.mkLuaInline "mod .. \" + SHIFT + V\"")
          (lib.mkLuaInline ''hl.dsp.exec_cmd("rofi -modi clipboard:${pkgs.cliphist}/bin/cliphist-rofi-img -show clipboard -show-icons")'')
        ];
      }
    ];
  };
}
