{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.tools.git;
in
{
  options.my.home.shell.tools.git = {
    enable = mkEnableOption "Enable git config";
    userName = mkOption {
      type = types.str;
      default = throw "config.my.home.shell.tools.git.userName must be set";
    };
    userEmail = mkOption {
      type = types.str;
      default = throw "config.my.home.shell.tools.git.userEmail must be set";
    };
  };
  config = mkIf cfg.enable {
    programs.git = {
      inherit (cfg) userName userEmail;
      package = pkgs.gitAndTools.gitFull;
      enable = true;
      lfs.enable = true;
      ignores = [
        "result"
        ".DS_STORE"
        ".envrc"
        "*~"
        "*.swp"
      ];
      extraConfig = {
        commit.gpgSign = true;
        init.defaultBranch = "main";
      };
    };
    home.sessionVariables.GIT_EDITOR = config.home.sessionVariables.EDITOR or "${pkgs.neovim}/bin/nvim";
  };
}
