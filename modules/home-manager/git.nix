{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.git;
in
{
  options.my.home.git = {
    enable = mkEnableOption "Enable git config";
    userName = mkOption {
      type = types.str;
      default = throw "config.my.home.git.userName must be set";
    };
    userEmail = mkOption {
      type = types.str;
      default = config.my.home.email.mainAddress;
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
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };
    home.sessionVariables.GIT_EDITOR = config.home.sessionVariables.EDITOR or "${pkgs.neovim}/bin/nvim";
  };
}
