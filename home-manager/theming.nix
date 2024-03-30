# { pkgs, config, ... }:
{
  # gtk = pkgs.lib.mkIf pkgs.stdenv.isLinux {
  #   gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  #   enable = true;
  #   font = {
  #     name = "JetBrainsMono Nerd Font";
  #     size = 12;
  #   };
  #   theme = {
  #     name = "Dracula";
  #     package = pkgs.dracula-theme;
  #     # name = "Nordic-darker";
  #     # package = pkgs.nordic;
  #   };
  # };
  xresources = {
    properties = {
      "*.foreground" = "#ABB2BF";
      "*.background" = "#1E2127";
      "*.cursorColor" = "#5C6370";
      "*.highlightColor" = "#3A3F4B";

      "*.color0" = "#1E2127";
      "*.color8" = "#5C6370";
      "*.color1" = "#E06C75";
      "*.color9" = "#E06C75";
      "*.color2" = "#98C379";
      "*.color10" = "#98C379";
      "*.color3" = "#D19A66";
      "*.color11" = "#D19A66";
      "*.color4" = "#61AFEF";
      "*.color12" = "#61AFEF";
      "*.color5" = "#C678DD";
      "*.color13" = "#C678DD";
      "*.color6" = "#56B6C2";
      "*.color14" = "#56B6C2";
      "*.color7" = "#ABB2BF";
      "*.color15" = "#FFFFFF";

    };
  };

}
