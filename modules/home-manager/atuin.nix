{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.atuin;
in
{
  options.my.home.atuin.enable = mkEnableOption "Enable atuin for shell history";
  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableFishIntegration = config.programs.fish.enable;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = false;
        db_path = "${config.xdg.dataHome}/atuin/atuin.db";
        search_mode = "fuzzy";
        update_check = false;
      };
    };
  };
}
