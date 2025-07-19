{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.zoxide;
in
{
  options.my.home.zoxide.enable = mkEnableOption "Enable zoxide instead of cd";
  config = mkIf cfg.enable {
    home.packages = [ pkgs.fzf ];
    programs.zoxide = {
      enable = true;
      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableNushellIntegration = config.programs.nushell.enable;
      options = [
        "--cmd cd"
        "--hook pwd"
      ];
    };
  };
}
