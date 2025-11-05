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
      enable = true;
      lfs.enable = true;
      ignores = [
        "result"
        ".DS_STORE"
        ".envrc"
        ".direnv"
        "*~"
        "*.swp"
      ];
      settings = {
        commit.gpgSign = true;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
      };
      includes = lists.optional config.my.home.school.enable {
        condition = "hasconfig:remote.*.url:https://github.gatech.edu/**";
        contents = {
          user = {
            email = "kbakheat3@gatech.edu";
            name = "kbakheat3";
          };
        };
      };
    };
    home.sessionVariables.GIT_EDITOR = config.home.sessionVariables.EDITOR or "${pkgs.neovim}/bin/nvim";
  };
}
