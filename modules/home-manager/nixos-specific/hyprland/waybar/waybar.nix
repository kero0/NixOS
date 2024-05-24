{
  pkgs,
  lib,
  osconfig,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland.waybar;
in
{
  options.my.home.hyprland.waybar.enable = mkEnableOption "Enable hyprland waybar";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pamixer
      pavucontrol
    ];
    programs.waybar = {
      catppuccin.mode = "prependImport";
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
      style = builtins.readFile ./theme.css;
      settings = [
        {
          layer = "bottom";
          position = "top";
          modules-left = [
            "hyprland/workspaces"
            "hyprland/window"
          ];
          modules-center = [ ];
          "hyprland/window" = {
            format = "{}";
            max-length = 85;
          };
          modules-right = [
            "idle_inhibitor"
            "pulseaudio"
            "backlight"
            "memory"
            "cpu"
            "network"
            "clock"
            "battery"
            "tray"
          ];
          idle_inhibitor = {
            format = " {icon} ";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };
          pulseaudio = {
            scroll-step = 1;
            format = "{icon} {volume:3}%";
            format-muted = "󰖁 Muted";
            format-icons = {
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pamixer -t";
            on-click-right = "pavucontrol";
            tooltip = false;
          };
          backlight = {
            format = "🔆 {percent:3}%";
          };
          memory = {
            interval = 1;
            format = "󰻠 {percentage:3}%";
            states = {
              warning = 85;
            };
          };
          cpu = {
            interval = 1;
            format = "󰍛 {usage:3}%";
          };
          network = {
            format-disconnected = "󰯡";
            format-ethernet = "";
            format-linked = "󰖪 {essid} (No IP)";
            format-wifi = "󰖩 {essid}";
            interval = 1;
            tooltip = false;
          };
          clock = {
            interval = 1;
            format = " {:%I:%M %p}";
            tooltip = true;
            tooltip-format = " {:%I:%M %p  %A %b %d}";
          };
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity:3}%";
            format-charging = "🔌 {capacity:3}%";
            format-alt = "{time} {icon}";
            # format-full = " {capacity}%";
            format-icons = [
              ""
              ""
              ""
              ""
            ];
          };
          tray = {
            icon-size = 15;
            spacing = 5;
          };
        }
      ];
    };
  };
}
