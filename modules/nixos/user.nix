{
  pkgs,
  lib,
  config,
  public-keys,
  ...
}:
let
  cfg = config.my.user;
in
with lib;
{
  options.my.user = {
    enable = mkEnableOption "Setup a user with my personal settings";
    username = mkOption {
      type = types.str;
      default = throw "config.my.user.username must be set";
    };
    passwordHash = mkOption {
      type = types.nullOr types.str;
      default = "$6$jAVQ7IamcuYQ7qVF$3rUJsm03bpI7SSrzFo2I8/aRQKcZ/upLH3l5NfqnxQWs8FgU2MlcbS0HnLXF2ehBR8dnAWj.ROuCsK91zzNgz.";
    };
    homedir = mkOption {
      type = types.str;
      default = if pkgs.stdenv.isDarwin then "/Users/${cfg.username}" else "/home/${cfg.username}";
    };
    shell = mkOption {
      type = types.str;
      default = "${pkgs.zsh}/bin/zsh";
    };
    realName = mkOption {
      type = types.str;
      default = "Kirols Bakheat";
    };
  };
  config = lib.mkIf cfg.enable {
    users =
      if pkgs.stdenv.isDarwin then
        {
          users."${cfg.username}" = {
            home = cfg.homedir;
            inherit (cfg) shell;
          };
        }
      else
        {
          users."${cfg.username}" = {
            createHome = true;
            home = cfg.homedir;
            hashedPassword = cfg.passwordHash;
            description = cfg.realName;
            inherit (cfg) shell;
            isNormalUser = true;
            extraGroups = [
              "audio"
              "dialout"
              "input"
              "kvm"
              "tty"
              "video"
              "wheel"
            ];
            openssh.authorizedKeys.keys = public-keys;
          };
          users.root.hashedPassword = cfg.passwordHash;
          mutableUsers = false;
        };
  };
}
