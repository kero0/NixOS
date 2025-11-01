{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.kitty;
in
{
  options.my.home.shell.kitty = {
    enable = mkEnableOption "Enable kitty shell";
    shell = mkOption {
      type = types.nullOr types.str;
      default = osConfig.my.user.shell or null;
    };

  };
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
        macos_quit_when_last_window_closed = lib.mkIf pkgs.stdenv.isDarwin "no";
        shell = lib.mkIf (cfg.shell != null) cfg.shell;

        draw_bold_text_with_bright_colors = true;

        font_size = 14.0;
        font_family = "JetBrainsMono Nerd Font";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

        background_opacity = 1;
        confirm_os_window_close = 0;
      };
    };
  };
}
