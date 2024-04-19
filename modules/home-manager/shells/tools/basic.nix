{
  pkgs,
  lib,
  osconfig,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.tools;
in
{
  options.my.home.shell.tools.enable = mkEnableOption "Basic shell tools";
  config = mkIf cfg.enable {
    programs = {
      command-not-found.enable = false;
      eza.enable = true;
      feh.enable = pkgs.lib.mkIf pkgs.stdenv.isLinux true;
      jq.enable = true;
      man.enable = true;
      zathura.enable = pkgs.lib.mkIf pkgs.stdenv.isLinux true;

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      fzf = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
