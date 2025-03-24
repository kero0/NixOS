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
      shellIntegration = {
        enableBashIntegration = config.programs.bash.enable;
        enableFishIntegration = config.programs.fish.enable;
        enableZshIntegration = config.programs.zsh.enable;
      };
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
      };
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        clipboard_control = "write-clipboard write-primary no-append";

        draw_bold_text_with_bright_colors = true;

        font_size = "14.0";
        font_family = "JetBrainsMono Nerd Font";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

        background_opacity = "1";
      };
    };
  };
}
