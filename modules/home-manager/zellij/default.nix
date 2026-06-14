{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.zellij;
in
{
  options.my.home.zellij.enable = mkEnableOption "zellij module";
  config = mkIf cfg.enable {
    programs = {
      zellij = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        exitShellOnExit = false;
        settings = {
          attach_to_session = true;
          session_name = "default";
          show_startup_tips = false;
          show_release_notes = false;
          default_mode = "locked";
          default_layout = "compact";
          scroll_buffer_size = 10 * 1024 * 1024;
          session_serialization = true;
          pane_viewport_serialization = 1024;
          pane_frames = false;
          ui = {
            pane_frames = {
              rounded_corners = true;
              hide_session_name = false;
            };
          };
          plugins = with pkgs.zellijPlugins; {
          };
          # load_plugins = {
          # };
        };
      };
    };
  };
}
