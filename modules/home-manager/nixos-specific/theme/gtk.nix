{ pkgs, lib, osconfig, config, ... }:
with lib;
let
  cfg = config.my.home.theme.gtk;
  in
  {
    options.my.home.theme.gtk.enable = mkEnableOption "Theme for GTK application";
    config = mkIf cfg.enable
      {
	gtk = {
          enable = true;
          theme = {
            name = "Catppuccin-Latte-Compact-Lavender-Light";
            package = pkgs.catppuccin-gtk.override {
              accents = [ "lavender" ];
              size = "compact";
              tweaks = [ "rimless" "float" ];
              variant = "latte";
            };
        };
      };
      xdg.configFile = {
        "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
        "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
      };
    };
}

