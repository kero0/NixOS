{ config, pkgs, ... }:
{
  programs.git = {
    lfs.enable = true;
    extraConfig = {
      github.user = "kero0";
      user.signingKey = "6203EA1E2A444A37709BF65023B20E88C6992499";
      push.autoSetupRemote = true;
    };
  };
}
