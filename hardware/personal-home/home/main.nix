{ config, pkgs, ... }:
{
  programs.git = {
    lfs.enable = true;
    extraConfig = {
      github.user = "kero0";
      user.signingKey = "E8228103022276B272DB6D75C58FF77AD5D76336";
      push.autoSetupRemote = true;
    };
  };
}
