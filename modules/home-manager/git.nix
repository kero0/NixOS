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
        rebase.autostash = true;
        merge.autostash = true;
        pull.autoStash = true;
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
      };
      includes = lists.optionals config.my.home.school.enable (
        let

          contents = {
            user = {
              email = "kbakheat3@gatech.edu";
              name = "kbakheat3";
              signingKey = "1AB9DFCE109F2A50DC4A61FC8348A11C840BFD05";
            };
          };
        in
        [
          {
            condition = "hasconfig:remote.*.url:https://github.gatech.edu/**";
            inherit contents;
          }
          {
            condition = "hasconfig:remote.*.url:git@github.gatech.edu:*/**";
            inherit contents;
          }
        ]
      );
    };
    home.sessionVariables.GIT_EDITOR = config.home.sessionVariables.EDITOR or "${pkgs.neovim}/bin/nvim";
  };
}
