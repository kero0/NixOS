{ pkgs, lib, config, ... }:
with lib;
let cfg = config.my.home.shell.tools.zellij;
in {
  options.my.home.shell.tools.zellij.enable = mkEnableOption "zellij module";
  config = mkIf cfg.enable {
    programs = {
      zellij = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        settings = {
          mirror_session = true;
          scrollback_lines_to_serialize = 300;
        };
      };
    };
  };
}
