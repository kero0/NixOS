{ lib, config, ... }:
with lib;
let
  cfg = config.my.home.shell.kitty;
in
{
  options.my.home.shell.kitty.enable = mkEnableOption "Enable kitty shell";
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
      };
      settings = {
        shell = mkIf config.my.home.shell.fish.enable "fish";

        scrollback_lines = 10000;
        enable_audio_bell = false;

        draw_bold_text_with_bright_colors = true;

        font_size = "14.0";
        font_family = "JetBrainsMono Nerd Font";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

        foreground = "#979eab";
        background = "#282c34";
        cursor = "#cccccc";
        color0 = "#282c34";
        color1 = "#e06c75";
        color2 = "#98c379";
        color3 = "#e5c07b";
        color4 = "#61afef";
        color5 = "#be5046";
        color6 = "#56b6c2";
        color7 = "#979eab";
        color8 = "#393e48";
        color9 = "#d19a66";
        color10 = "#56b6c2";
        color11 = "#e5c07b";
        color12 = "#61afef";
        color13 = "#be5046";
        color14 = "#56b6c2";
        color15 = "#abb2bf";
        selection_foreground = "#282c34";
        selection_background = "#979eab";
        background_opacity = "0.85";
      };
    };
  };
}
