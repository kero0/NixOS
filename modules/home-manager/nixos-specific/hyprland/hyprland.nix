{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland;
in
{
  options.my.home.hyprland.enable = mkEnableOption "Enable hyprland window manager";
  config = mkIf cfg.enable {
    xdg.configFile."uwsm/env".source =
      "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    home.packages = with pkgs; [
      grim
      playerctl
      swaynotificationcenter
      wdisplays
      wl-clipboard
    ];
    services = {
      hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          ipc = true;
          wallpaper = [
            {
              monitor = "";
              path = "${config.xdg.configHome}/wallpapers/";
              timeout = 45 * 60;
            }
          ];
        };
      };
      hyprpolkitagent.enable = true;
    };

    catppuccin.hyprland.enable = false;
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      systemd = {
        enable = true;
        variables = [ "--all" ];
      };
      xwayland.enable = true;
      settings = {
        monitor = {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        };
        config = [
          { master.new_status = "master"; }
          { dwindle.preserve_split = true; }
          { ecosystem.no_update_news = true; }
          {
            input = {
              kb_layout = "us";
              follow_mouse = 1;
              touchpad = {
                natural_scroll = true;
                scroll_factor = 0.5;
              };
              sensitivity = 0;
            };
          }
          {
            misc = {
              force_default_wallpaper = -1;
              disable_hyprland_logo = true;
              enable_swallow = true;
            };
          }
        ];
        env =
          lib.mapAttrsToList
            (k: v: {
              _args = [
                k
                (toString v)
              ];
            })
            {
              "XCURSOR_SIZE" = 24;
              "QT_QPA_PLATFORMTHEME" = "qt5ct";
              "NIXOS_OZONE_WL" = 1;
              "ELECTRON_OZONE_PLATFORM_HINT" = "wayland";
            };
      };
    };
  };
}
