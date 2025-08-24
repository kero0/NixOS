{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.gh;
in
{
  options.my.home.gh = {
    enable = mkEnableOption "Enable github cli config";
  };
  config = mkIf cfg.enable {
    programs.gh = {
      enable = true;
      extensions = with pkgs; [
        gh-copilot
        gh-eco
        gh-poi
        gh-s
      ];
      settings = {
        aliases = { };
        editor = lib.mkIf (config.home.sessionVariables ? EDITOR) config.home.sessionVariables.EDITOR;
        git.protocol = "ssh";
        gitCredentialsHelper = {
          enable = true;
          hosts = [
            "https://github.gatech.edu"
            "https://github.com"
          ];
        };
      };
    };
    programs.gh-dash = {
      enable = true;
      settings = { };
    };
  };
}
