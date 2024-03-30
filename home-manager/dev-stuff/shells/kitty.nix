{ config, lib, pkgs, ... }: {
      programs.kitty = lib.mkIf (!pkgs.stdenv.isDarwin) {
            enable = true;
            keybindings = {
                  "ctrl+c" = "copy_or_interrupt";
                  "ctrl+n" = "map f1 launch --cwd=current";
                  "ctrl+t" = "launch --cwd=current --type=tab";
            };
            settings = {
                  shell = "fish";

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
                  background_opacity = "0.7";
    };
  };
}
