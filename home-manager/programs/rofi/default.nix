{ pkgs, ... }:
{
  programs.rofi = pkgs.lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    plugins = with pkgs;[
      rofi-calc
      rofi-emoji
      rofi-power-menu
    ];
    font = "JetBrainsMono Nerd Font 14";
    terminal = "${pkgs.kitty}/bin/kitty";
    cycle = true;
    location = "center";
    theme = ./onedark.rasi;
    extraConfig = {
      modi = "drun,run,emoji,calc,window,ssh,";
      kb-primary-paste = "Control+V,Shift+Insert";
      kb-secondary-paste = "Control+v,Insert";
      matching = "regex";
      dpi = 1;
    };
  };
}
