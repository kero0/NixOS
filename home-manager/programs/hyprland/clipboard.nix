{ pkgs, ... }: {
  services.cliphist.enable = true;
  systemd.user.services = {
    wl-clip-persist = {
      Unit = {
        Description = "Persist clipboard when application exits";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
        Restart = "always";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };

  wayland.windowManager.hyprland.settings = {
    "$cliphist-rofi-img" = "${pkgs.cliphist-rofi-img}/bin/cliphist-rofi-img";
    bind = [
      "$mod SHIFT , V,      exec, rofi -modi clipboard:$cliphist-rofi-img -show clipboard -show-icons"
    ];
  };
}
